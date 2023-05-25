const functions = require('firebase-functions');
const admin = require('firebase-admin');
const messaging = require('./messaging');
const utils = require('./utils');
const { GeoCollectionReference, GeoFirestore, GeoQuery, GeoQuerySnapshot } = require('geofirestore');


// GeoFirestore
const geofirestore = new GeoFirestore(admin.firestore());
const geocollection = geofirestore.collection('userLocations');

//////////////////////////////////////////////////
//
// helpers
//

function getChatForUsers(users) {

  let promise = admin.firestore().collection("chats")
  for (var i = 0; i < users.length; i++) {
    promise = promise.where("memberIds." + users[i], "==", true);
  }

  return promise
  .get()
  .then((chats) => {
    let selectedChatRef = undefined;
    chats.forEach((chatRef) => {
      const chat = chatRef.data();
      if (Object.keys(chat.memberIds).length === users.length && chat.type !==  "group") {
        selectedChatRef = chatRef;
      }
    });
    return selectedChatRef;
  })
}

function sendMessageToChat(userA, userB, message) {
  return getChatForUsers([userA, userB])
  .then((chatRef) => {
    // insert request message
    if (chatRef !== null && chatRef !== undefined) {
      return admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(message);
    }
    return null;
  })
}

function cancelPostsAndRequest(userId, excludedPostId) {

  return admin.firestore().collection("users/" + userId + "/posts")
    .get()
    .then((posts) => {

      if (posts === null || posts === undefined) return null;

      let promiseStack = []; 
      posts.forEach((postRef) => {
        const postId = postRef.id;
        const post = postRef.data();
        const promise = admin.firestore().doc('experiences/' + post.experience.id + '/postList/' + postId).delete();
        promiseStack.push(promise);
      });
      return Promise.all(promiseStack);
    })
    .then(() => {
      return admin.firestore().collection("users/" + userId + "/requests").get();
    })
    .then((requests) => {

      if (requests === null || requests === undefined) return null;

      let promiseStack = [];
      requests.forEach((requestRef) => {
        const requestId = requestRef.id;
        const request = requestRef.data();
        if (excludedPostId !== request.post.id) {
          const promise = admin.firestore()
            .doc('experiences/' + request.post.experience.id + '/postList/' + request.post.id + '/requestList/' + requestId)
            .update({ "accepted": false });
          promiseStack.push(promise);
        }
      });
      return Promise.all(promiseStack);
    });
}

function closeTime(timeId, time) {
  return admin.firestore().doc("chats/" + time.chat.id).update({ "archived": true })
  .then(() => {
    // TODO: - how do we handle this? just close it?
    return admin.firestore().doc("experiences/" + time.post.experience.id + "/timeList/" + timeId).delete();
  });
}

function timeListChanged(before, after) {
  let beforeNotNull = {};
  if (before !== undefined && before !== null) {
    beforeNotNull = before;
  }
  let afterNotNull = {};
  if (after !== undefined && after !== null) {
    afterNotNull = after;
  }
  let changes = {};
  let keys = Object.keys(beforeNotNull);
  var i;
  for(i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (beforeNotNull[key] !== afterNotNull[key]) {
      changes[key] = afterNotNull[key];
    }
  }
  keys = Object.keys(afterNotNull);
  for(i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (beforeNotNull[key] !== afterNotNull[key]) {
      changes[key] = afterNotNull[key];
    }
  }
  return changes;
}

function allArrived(time) {

  const memberIds = time.chat.memberIds;
  let allArrived = true;
  let states = {};
  if (time.states !== undefined && time.states !== null) {
    states = time.states;
  }
  for(var i = 0; i < memberIds.length; i++) {
    const userId = memberIds[i];
    if (states[userId] !== "arrived" && states[userId] !== "cancelled" && states[userId] !== "closed") {
      allArrived = false;
      break;
    }
  }
  return allArrived;
}

function allMet(time) {

  const memberIds = time.chat.memberIds;
  let allMet = true;
  let states = {};
  if (time.states !== undefined && time.states !== null) {
    states = time.states;
  }
  for(var i = 0; i < memberIds.length; i++) {
    const userId = memberIds[i];
    if (states[userId] !== "met" && states[userId] !== "cancelled" && states[userId] !== "closed") {
      allMet = false;
      break;
    }
  }
  return allMet;
}

function updateForAllArrived(timeId, time) {
  let update = {};
  const memberIds = time.chat.memberIds;
  let states = {};
  if (time.states !== undefined && time.states !== null) {
    states = time.states;
  }
  for(var i = 0; i < memberIds.length; i++) {
    const userId = memberIds[i];
    if (states[userId] === "arrived") {
      update["states." + userId] = "queryMet";
    }
  }
  return admin.firestore().doc("experiences/" + time.post.experience.id + "/timeList/" + timeId)
    .update(update);
}

function updateNumberOfTimes(time) {
  let promiseStack = [];
  const memberIds = time.chat.memberIds;
  for(var i = 0; i < memberIds.length; i++) {
    const userId = memberIds[i];
    if (time.states[userId] === "met") {
      const promise = admin.firestore().doc('users/' + userId).update({ "numberOfGoings": admin.firestore.FieldValue.increment(1) });
      promiseStack.push(promise);
    }
  }
  return Promise.all(promiseStack);
}

function updateHistory(timeId, log) {
  let promiseStack = [];
  const memberIds = log.time.chat.memberIds;
  for(var i = 0; i < memberIds.length; i++) {
    const userId = memberIds[i];
    const promise = admin.firestore().doc('users/' + userId + '/history/' + timeId).set(log);
    promiseStack.push(promise);
  }
  return Promise.all(promiseStack);
}

function insertChatMember(chatId, user) {
  return admin.firestore().doc("chats/" + chatId)
  .get()
  .then((chatRef) => {
  
    // cannot add the member
    if (chatRef === null || chatRef === undefined) {
      return null;
    }

    const chatId = chatRef.id;
    const chat = chatRef.data();

    let allOk = true;
    if (chat.memberIds[user.id] !== true) {
      allOk = false;
    }

    let promiseStack = [];

    // need to update the members
    if (!allOk) {
      
      let update = {};
      update["members"] = admin.firestore.FieldValue.arrayUnion(user);
      update["memberIds." + user.id] = true;

      // update members
      let promise = admin.firestore().doc("chats/" + chatId).update(update);

      // send message
      let msg = {
        createdAt: utils.now(),
        sender: user,
        type: "joined",
        text: user.name + " joined"
      };  
      promise = admin.firestore().collection("chats/" + chatId + "/messageList").add(msg);
      promiseStack.push(promise);
    }

    return Promise.all(promiseStack);
  });
}

function removeChatMember(chatId, userId) {
  return admin.firestore().doc("chats/" + chatId)
  .get()
  .then((chatRef) => {
  
    // cannot remove the member
    if (chatRef === null || chatRef === undefined) {
      return null;
    }

    const chatId = chatRef.id;
    const chat = chatRef.data();

    let promiseStack = [];
    let allOk = true;
    let user = null;

    // removing members only in group chats
    if (chat.type === "group") {
      for (var i = 0; i < chat.members.length; i++) {
        if (chat.members[i].id === userId) {
          user = chat.members[i];
          allOk = false;
          break;
        }
      }
    }

    // need to update the members
    if (!allOk) {

      // delete the chat if there are less 3 members
      if (chat.members.length <= 2) {
        let promise = admin.firestore().doc("chats/" + chatId).delete();
        promiseStack.push(promise);
      } else {
        let update = {};

        update["members"] = admin.firestore.FieldValue.arrayRemove(user);
        update["memberIds." + userId] = admin.firestore.FieldValue.delete();

        // update members
        let promise = admin.firestore().doc("chats/" + chatId).update(update);

        // send message
        let msg = {
          createdAt: utils.now(),
          sender: user,
          type: "text",
          text: user.name + " left"
        };  
        promise = admin.firestore().collection("chats/" + chatId + "/messageList").add(msg);
        promiseStack.push(promise);
      }
    }

    return Promise.all(promiseStack);
  });
}

function updateExperiencePostExpiration(experienceId) {
  
  return admin.firestore().collection("experiences/" + experienceId + "/postList").get()
  .then((posts) => {

    // update experience post expiration
    if (posts === null || posts === undefined) return null;

    let minTime = -1;
    posts.forEach((postRef) => {
      const postId = postRef.id;
      const post = postRef.data();

      if (minTime === -1 || minTime > post.expiresAt) {
        minTime = post.expiresAt;
      }
    });

    return admin.firestore().doc('experiences/' + experienceId).update({ "postExpiresAt": minTime });
  });
}

function updateExperienceTimeExpiration(experienceId) {
  
  return admin.firestore().collection("experiences/" + experienceId + "/timeList").get()
  .then((times) => {

    // update experience time expiration
    if (times === null || times === undefined) return null;

    let minTime = -1;
    times.forEach((timeRef) => {
      const timeId = timeRef.id;
      const time = timeRef.data();

      if (minTime === -1 || minTime > time.expiresAt) {
        minTime = time.expiresAt;
      }
    });

    return admin.firestore().doc('experiences/' + experienceId).update({ "timeExpiresAt": minTime });
  });
}

function notifyNearbyUsersAboutPost(postId, post) {

  if (post.location === undefined || post.location === null || post.isSilent === true) {
    return null;
  }

  return geocollection.near({ center: post.location, radius: 1 }).get()
  .then((value) => { 
    let promiseStack = [];
    for (var i = 0; i < value.docs.length; i++) {
      const userId = value.docs[i].id;

      if (userId === post.creator.id) {
        continue;
      }

      let params = {};
      params['type'] = 'newPost';
      params['postId'] = postId;
      params['experienceId'] = post.experience.id;
      params['senderId'] = post.creator.id;

      const title = post.experience.title;
      let msgText = post.creator.name + " wants to \"" + post.experience.text + "\"";
      if (msgText.length > 200) {
        msgText = msgText.substring(0, 197) + "...";
      }

      promise = messaging.sendMessage_firestore(userId, title, msgText, params, '10');
      promiseStack.push(promise);
    }
    return Promise.all(promiseStack);
  });
}

function notifyCreatorAboutPost(postId, post) {

  if (post.experience.creator.id === post.creator.id || post.isSilent === true) {
    return null;
  }

  let params = {};
  params['type'] = 'newPost';
  params['postId'] = postId;
  params['experienceId'] = post.experience.id;
  params['senderId'] = post.creator.id;

  const title = post.experience.title;
  const msgText = post.creator.name + " wants to do \"" + post.experience.title + "\"";

  return messaging.sendMessage_firestore(post.experience.creator.id, title, msgText, params, '10');
}

function notifyCreatorAboutLike(like) {

  if (like.experience.creator.id === like.creator.id) {
    return null;
  }

  let params = {};
  params['type'] = 'newLike';
  params['experienceId'] = like.experience.id;
  params['senderId'] = like.creator.id;

  const title = like.experience.title;
  const msgText = like.creator.name + " likes \"" + like.experience.title + "\"";

  return messaging.sendMessage_firestore(like.experience.creator.id, title, msgText, params, '10');
}

function notifyCreatorAboutTime(time) {

  return admin.firestore().doc('chats/' + time.chat.id).get()
  .then((chatRef) => {

    let memberNames = "";
    const chatData = chatRef.data();
    for(var i = 0; i < chat.members.length; i++) {
      const user = chat.members[i];

      if (memberNames.length > 0) {
        if (i < chat.members.length - 1) {
          memberNames = memberNames + ", ";
        } else {
          memberNames = memberNames + " and ";
        }
      }
      memberNames = memberNames + user.name;
    }

    if (memberNames.length === 0) {
      return null;
    }

    let params = {};
    params['type'] = 'newPost';
    params['postId'] = postId;
    params['experienceId'] = time.post.experience.id;
    params['senderId'] = time.post.creator.id;

    const title = time.post.experience.title;
    let msgText = "Great news! " + memberNames + " just used \"" + time.time.post.experience.title + "\"";
    if (chat.members.length <= 2) {
      msgText = msgText + " to create a new Time"
    }
    msgText = msgText + ".";
    return messaging.sendMessage_firestore(time.post.experience.creator.id, title, msgText, params, '10');
  })
  .catch((error) => {
    console.log("Chat message read failed: " + error);
  });
}

function addPostChatMember(postId, post, user) {

  let promiseStack = [];

  // add chat member
  let promise = insertChatMember(post.chat.id, user);
  promiseStack.push(promise);

  // add member from chat list  
  let update = {};
  update["chat.memberIds"] = admin.firestore.FieldValue.arrayUnion(user.id);
  promise = admin.firestore().doc('experiences/' + post.experience.id + '/postList/' + postId).update(update);
  
  return Promise.all(promiseStack);
}

function removePostChatMember(postId, post, userId) {

  let promiseStack = [];

  // remove chat member
  let promise = removeChatMember(post.chat.id, userId);
  promiseStack.push(promise);

  // remove member from chat list
  if (post.chat.type === "group") {
    let update = {};
    if (post.chat.memberIds.length < 3) {
      // group chat is destroyed
      update["chat"] = admin.firestore.FieldValue.delete();
    } else {
      // just remove the member  
      update["chat.memberIds"] = admin.firestore.FieldValue.arrayRemove(userId);
    }
    promise = admin.firestore().doc('experiences/' + post.experience.id + '/postList/' + postId).update(update);
  }
  
  return Promise.all(promiseStack);
}

function removeTimeMember(timeId, time, userId) {

  let promiseStack = [];

  // remove chat member
  let promise = removeChatMember(time.chat.id, userId);
  promiseStack.push(promise);

  // remove member from chat list
  if (time.chat.type === "group") {
    let update = {};
    update["chat.memberIds"] = admin.firestore.FieldValue.arrayRemove(userId);
    promise = admin.firestore().doc('experiences/' + time.post.experience.id + '/timeList/' + timeId).update(update);
  }
  
  return Promise.all(promiseStack);
}

//////////////////////////////////////////////////
//
// scheduled jobs
//

// experience post list cleanup -> removes posts if they are expired
exports.fivemin_job = functions.pubsub
  .topic('fivemin-tick')
  .onPublish((message) => {

    const nowTime = utils.now();

    return admin.firestore().collection("experiences")
    .where("postExpiresAt", ">", 0)
    .where("postExpiresAt", "<", nowTime)
    .get()
    .then((experiences) => {

      if (experiences === null || experiences === undefined) return null;

      let promiseStack = [];
      experiences.forEach((child) => {
        const experienceId = child.id;
        let promise = admin.firestore().collection("experiences/" + experienceId + "/postList").get()
        .then((posts) => {
          if (posts === null || posts === undefined) return null;

          let promiseStack = [];
          posts.forEach((postRef) => {

            const postId = postRef.id;
            const post = postRef.data();

            if (post.expiresAt <= nowTime) {
              const promise = admin.firestore().doc("experiences/" + experienceId + "/postList/" + postId).delete();
              promiseStack.push(promise);
            }
          });
          return Promise.all(promiseStack);
        });
        promiseStack.push(promise);
      });
      return Promise.all(promiseStack);
    });
  });

// experience time list cleanup -> closes times if they are expired
exports.tenmin_job = functions.pubsub
  .topic('tenmin-tick')
  .onPublish((message) => {

    const nowTime = utils.now();

    return admin.firestore().collection("experiences")
    .where("timeExpiresAt", ">", 0)
    .where("timeExpiresAt", "<", nowTime)
    .get()
    .then((experiences) => {

      if (experiences === null || experiences === undefined) return null;

      let promiseStack = [];
      experiences.forEach((child) => {
        const experienceId = child.id;
        let promise = admin.firestore().collection("experiences/" + experienceId + "/timeList").get()
        .then((times) => {
          if (times === null || times === undefined) return null;

          let promiseStack = [];
          times.forEach((timeRef) => {

            const timeId = timeRef.id;
            const time = timeRef.data();

            if (time.expiresAt < nowTime) {
              const promise = closeTime(timeId, time);
              promiseStack.push(promise);
            }
          });
          return Promise.all(promiseStack);
        });
        promiseStack.push(promise);
      });
      return Promise.all(promiseStack);
    });
  });

// TODO: --
exports.hourly_job = functions.pubsub
  .topic('hourly-tick')
  .onPublish((message) => {
    return true;
  });

// TODO: --
exports.hourly1_4_job = functions.pubsub
  .topic('hourly1-4-tick')
  .onPublish((message) => {
    return true;
  });

// TODO: --
exports.hourly1_2_job = functions.pubsub
  .topic('hourly1_2-tick')
  .onPublish((message) => {
    return true;
  });

// TODO: --
exports.hourly3_4_job = functions.pubsub
  .topic('hourly3_4-tick')
  .onPublish((message) => {
    return true;
  });

exports.daily_job = functions.pubsub
  .topic('daily-tick')
  .onPublish((message) => {
    console.log("This job is run every day!");
    return true;
  });


//////////////////////////////////////////////////
//
// tracking experiences
//

////////////////////////////////////
// Track experience creation
exports.experienceCreate = functions.firestore
  .document('experiences/{experienceId}')
  .onCreate((change, context) => {

    const experience = change.data();
    return admin.firestore().doc('users/' + experience.creator.id).update({ "numberOfDesigned": admin.firestore.FieldValue.increment(1) });
  });

////////////////////////////////////
// Track post creation
exports.postCreate = functions.firestore
  .document('experiences/{experienceId}/postList/{postId}')
  .onCreate((change, context) => {

    const post = change.data();
    const shortPost = utils.shortPostFromPost_firestore(post);

    return admin.firestore().doc("users/" + post.creator.id + "/posts/" + context.params.postId).set(shortPost)
    .then(() => {
      return updateExperiencePostExpiration(context.params.experienceId);
    })
    .then(() => {
      return notifyNearbyUsersAboutPost(context.params.postId, post);
    })
    .then(() => {
      return notifyCreatorAboutPost(context.params.postId, post);
    })
    .catch((error) => {
      console.error("Experience post create failed: " + error);
    });
  });

////////////////////////////////////
// Track post requests creation
exports.requestCreate = functions.firestore
  .document('experiences/{experienceId}/postList/{postId}/requestList/{requestId}')
  .onCreate((change, context) => {

    const request = change.data();
    const shortRequest = utils.shortRequestFromRequest_firestore(request); 
    const creatorId = request.post.creator.id; 
    const senderId = request.creator.id;
    const senderName = request.creator.name;

    return admin.firestore()
    .doc("users/" + senderId + "/requests/" + context.params.requestId)
    .set(shortRequest)
    .then(() => {
      // get chat

      if (request.post.experience.isVirtual === true) {
        return null;
      }
      return getChatForUsers([creatorId, senderId]);
    })
    .then((chatRef) => {
      // create chat if necessary

      if (request.post.experience.isVirtual === true) {
        return null;
      }

      let selectedChatRef = chatRef;
      if (selectedChatRef === undefined) {
        let memberIds = {};
        memberIds[creatorId] = true;
        memberIds[senderId] = true;
        let chat = {
          createdAt: utils.now(),
          members: [request.post.creator, request.creator],
          memberIds: memberIds,
          typing: []
        };
        return admin.firestore().collection("chats").add(chat);
      }
      return selectedChatRef;
    })
    .then((chatRef) => {
      // insert request message

      if (request.post.experience.isVirtual === true) {
        return null;
      }

      let msg = {
        createdAt: utils.now(),
        sender: request.creator,
        type: "request",
        text: request.post.experience.text
      };

      let promiseStack = [];
      let promise = admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(msg);
      promiseStack.push(promise);

      // insert user request message
      if (request.message !== null && request.message !== undefined) {
        let msg = {
          createdAt: utils.now() + 1,
          sender: request.creator,
          type: "text",
          text: request.message
        };
        promise = admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(msg);
        promiseStack.push(promise);
      }
      
      return Promise.all(promiseStack);
    })
    .then(() => {
      // Send message

      if (request.post.experience.isVirtual === true) {
        return null;
      }

      let params = {};
      params['type'] = 'newRequest';
      params['requestId'] = context.params.requestId;
      params['postId'] = context.params.postId;
      params['experienceId'] = context.params.experienceId;
      params['senderId'] = senderId;

      const userId = creatorId;
      const title = 'New Time Request';
      const msgText = senderName + ' is requesting a Time with you!';

      return messaging.sendMessage_firestore(userId, title, msgText, params, '10');
    })
    .catch((error) => {
      console.error("Experience Post Request create failed: " + error);
    });
  });

////////////////////////////////////
// Track post requests acceptance
exports.requestUpdate = functions.firestore
  .document('experiences/{experienceId}/postList/{postId}/requestList/{requestId}')
  .onUpdate((change, context) => {

    const requestId = context.params.requestId;
    const request = change.after.data();

    if (request.accepted === undefined || request.accepted === null) {
      return null;
    }

    // get post
    return change.after.ref.parent.parent
    .get()
    .then((postRef) => {

      const postId = postRef.id;
      const post = postRef.data();

      // chat does not exist
      if (post.chat === undefined || post.chat === null) {
        if (request.accepted === false) {
          // removing the request from tracking
          return admin.firestore().doc("users/" + request.creator.id + "/requests/" + requestId).delete()
            .then(() => {
              // sending message in the chat -> decide what kind
              let msg = {
                createdAt: utils.now(),
                sender: request.post.creator,
                type: "expired",
                text: request.signal.text
              };
              return sendMessageToChat(request.post.creator.id, request.creator.id, msg);
            });
        }
        return null;
      }

      if (request.accepted === true) {
        return addPostChatMember(postId, post, request.creator);
      } else if (request.accepted === false) {
        return removePostChatMember(postId, post, request.creator.id); 
      }

      return null;
    })
    .catch((error) => {
      console.error("Experience Post Request update failed: " + error);
    });
  });

////////////////////////////////////
// Track post starting
exports.postUpdate = functions.firestore
  .document('experiences/{experienceId}/postList/{postId}')
  .onUpdate((change, context) => {

    const postBefore = change.before.data();
    const postAfter = change.after.data();
  
    // location is set
    if ((postBefore.location === undefined || postBefore.location === null) && (postAfter.location !== undefined && postAfter.location !== null)) {
      return notifyNearbyUsersAboutPost(context.params.postId, postAfter);
    }

    // it has started 
    if ((postBefore.started === undefined || postBefore.started === null || postBefore.started === false) && postAfter.started === true) {

      const nowTime = utils.now();

      let shortPost = utils.shortPostFromPost_firestore(postAfter);
      shortPost["id"] = context.params.postId;

      let time = {
        id: context.params.postId,
        createdAt: nowTime,
        expiresAt: nowTime + 10800,
        post: shortPost
      }

      if (postAfter.chat !== undefined && postAfter.chat !== null) {
        time['chat'] = postAfter.chat;
      } else {
        time['chat'] = {
          id: "?",
          memberIds: []
        }
      }
      if (postAfter.meeting !== undefined && postAfter.meeting !== null) {
        time['meeting'] = postAfter.meeting;
      } else if (postAfter.experience.destination !== undefined && postAfter.experience.destination !== null) {
        time['meeting'] = postAfter.experience.destination;
      }

      // 1.) create time
      return admin.firestore()
      .doc('experiences/' + context.params.experienceId + '/timeList/' + context.params.postId)
      .set(time)
      .then(() => {
        // 2.) delete post
        return admin.firestore()
        .doc('experiences/' + context.params.experienceId + '/postList/' + context.params.postId)
        .delete();
      })
      .then(() => {
        // 3.) add tracking for time to members
        let promiseStack = [];
        for (var i = 0; i < time.chat.memberIds.length; i++) {
          const userId = time.chat.memberIds[i];
          const promise = admin.firestore().doc("users/" + userId + "/times/" + time.id).set(time);
          promiseStack.push(promise);
        }
        return Promise.all(promiseStack);
      })
      .then(() => {
        // 4.) close all requests & posts by members
        let promiseStack = [];
        for (var i = 0; i < time.chat.memberIds.length; i++) {
          const userId = time.chat.memberIds[i];
          const promise = cancelPostsAndRequest(userId, context.params.postId);
          promiseStack.push(promise);
        }
        return Promise.all(promiseStack);
      })
      .then(() => {
        // sending message in the chat
        let msg = {
          createdAt: utils.now(),
          sender: postAfter.creator,
          type: "started",
          text: "Let's go!"
        };

        if (postAfter.chat !== undefined && postAfter.chat !== null) {
          return admin.firestore().collection("chats/" + postAfter.chat.id + "/messageList").add(msg);
        } else {
          return null;
        }
      })
      .catch((error) => {
        console.error("Signal response read failed: " + error);
      });
    }

    return null;
  });

////////////////////////////////////
// Track time creations
exports.timeCreate = functions.firestore
  .document('experiences/{experienceId}/timeList/{timeId}')
  .onCreate((change, context) => {

    const time = change.data();
    // update time expiration
    return updateExperienceTimeExpiration(context.params.experienceId)
    .then(() => {
      return notifyCreatorAboutTime(time);
    })
    .catch((error) => {
      console.error("Experience time created failed: " + error);
    });

  });


////////////////////////////////////
// Track time changes
exports.timeUpdate = functions.firestore
  .document('experiences/{experienceId}/timeList/{timeId}')
  .onUpdate((change, context) => {

    const timeBefore = change.before.data();
    const timeAfter = change.after.data();
    var i;

    // check state
    const stateChanges = timeListChanged(timeBefore.states, timeAfter.states);
    let keys = Object.keys(stateChanges);
    if (keys.length > 0) {

      let promiseStack = [];

      // check if all met
      if (allMet(timeAfter) === true) {

        // update number of goings
        let promise = updateNumberOfTimes(timeAfter);
        promiseStack.push(promise);

        // create history log
        let shortTime = {
          id: context.params.timeId,
          createdAt: timeAfter.createdAt,
          expiresAt: timeAfter.expiresAt,
          post: timeAfter.post,
          chat: timeAfter.chat
        }
        let log = {
          createdAt: utils.now(),
          time: shortTime,
          images: []
        }
        promise = admin.firestore().doc("experiences/" + context.params.experienceId + "/historyList/" + context.params.timeId).set(log);
        promiseStack.push(promise);

        // delete time
        promise = admin.firestore().doc("experiences/" + context.params.experienceId + "/timeList/" + context.params.timeId).delete();
        promiseStack.push(promise);

        // add history to members
        promise = updateHistory(context.params.timeId, log);
        promiseStack.push(promise);

        return Promise.all(promiseStack)
        .catch((error) => {
          console.error("Experience Time update failed: " + error);
        });
      }

      // check if all arrived
      if (allArrived(timeAfter) === true) {

        const promise = updateForAllArrived(context.params.timeId, timeAfter);
        promiseStack.push(promise);
        return Promise.all(promiseStack)
        .catch((error) => {
          console.error("Experience Time update failed: " + error);
        });
      }

      for(i = 0; i < keys.length; i++) {
        const userId = keys[i];
        const userState = stateChanges[userId];

        let states = {};
        if (timeAfter.states !== undefined && timeAfter.states !== null) {
          states = timeAfter.states;
        }

        if (userState === "arrived") {

          const promise = admin.firestore().doc("users/" + userId).get()
          .then((userRef) => {
            const user = userRef.data();
            const title = user.name + " has arrived!";
            const text = "Great news! " + user.name  + " just arrived at the meeting point.";

            var params = {};
            params['timeId'] = context.params.timeId;
            params['experienceId'] = context.params.experienceId;
            params['postId'] = timeAfter.post.id;
            params['userId'] = userId;
            params['type'] = 'timeArrived';

            let promiseStack = [];
            for(var i = 0; i < timeAfter.chat.memberIds.length; i++) {
              const memberId = timeAfter.chat.memberIds[i];
              if (memberId !== userId && (states[memberId] !== "cancelled" || states[memberId] !== "closed")) {
                const promise = messaging.sendMessage_firestore(userId, title, text, params, '10');
                promiseStack.push(promise);
              }
            }
            return Promise.all(promiseStack);
          });
          promiseStack.push(promise);
        }

        if (userState === "met") {

          const promise = admin.firestore().doc("users/" + userId).get()
          .then((userRef) => {
            const user = userRef.data();
            const title = user.name + " says you've met!";
            const text = user.name  + " says you've found each other. Please confirm to end navigation.";

            var params = {};
            params['timeId'] = context.params.timeId;
            params['experienceId'] = context.params.experienceId;
            params['postId'] = timeAfter.post.id;
            params['userId'] = userId;
            params['type'] = 'timeMet';

            let promiseStack = [];
            for(var i = 0; i < timeAfter.chat.memberIds.length; i++) {
              const memberId = timeAfter.chat.memberIds[i];
              if (memberId !== userId && (states[memberId] !== "met" || states[memberId] !== "cancelled" || states[memberId] !== "closed")) {
                const promise = messaging.sendMessage_firestore(userId, title, text, params, '10');
                promiseStack.push(promise);
              }
            }
            return Promise.all(promiseStack);
          });
          promiseStack.push(promise);
        }

        if (userState === "cancelled") {
          
          let promise = admin.firestore().doc("users/" + userId).get()
          .then((userRef) => {
            const user = userRef.data();
            const title = user.name + " cancelled!";
            const text = user.name  + " cannot make it. Sorry :(";

            var params = {};
            params['timeId'] = context.params.timeId;
            params['experienceId'] = context.params.experienceId;
            params['postId'] = timeAfter.post.id;
            params['userId'] = userId;
            params['type'] = 'timeCancelled';

            let promiseStack = [];
            for(var i = 0; i < timeAfter.chat.memberIds.length; i++) {
              const memberId = timeAfter.chat.memberIds[i];
              if (memberId !== userId && (states[memberId] !== "cancelled" || states[memberId] !== "closed")) {
                const promise = messaging.sendMessage_firestore(userId, title, text, params, '10');
                promiseStack.push(promise);
              }
            }
            return Promise.all(promiseStack);
          });
          promiseStack.push(promise);

          promise = removeTimeMember(context.params.experienceId, timeAfter, userId);
          promiseStack.push(promise);
        }
      }        
          
      return Promise.all(promiseStack)
      .catch((error) => {
        console.error("Experience Time update failed: " + error);
      });
    }

    // check location
    const distanceChanges = timeListChanged(timeBefore.distances, timeAfter.distances);
    keys = Object.keys(distanceChanges);
    if (keys.length > 0) {

      let promiseStack = [];
      for(i = 0; i < keys.length; i++) {
        const userId = keys[i];
        const userDistance = distanceChanges[userId];
        let userState = undefined;
        if (timeAfter.states !== undefined && timeAfter.states !== null) {
          userState = timeAfter.states[userId];
        }

        if (userState === "queryArrived" || userState === "arrived" || userState === "queryMet" || userState === "met" || userState === "closed" || userState === "cancelled") {
          continue;
        }

        if (userDistance < 15) {
          let update = {};
          update["states." + userId] = "queryArrived";
          let promise = admin.firestore().doc("experiences/" + context.params.experienceId + "/timeList/" + context.params.timeId)
            .update(update);
          promiseStack.push(promise);

          const title = "Did you arrive?";
          const text = "Please confirm you're at the meeting point.";
          
          var params = {};
          params['timeId'] = context.params.timeId;
          params['experienceId'] = context.params.experienceId;
          params['postId'] = timeAfter.post.id;
          params['userId'] = userId;
          params['type'] = 'timeQueryArrived';

          promise =  messaging.sendMessage_firestore(userId, title, text, params, '10');
          promiseStack.push(promise);
        }
      }

      return Promise.all(promiseStack)
      .catch((error) => {
        console.error("Experience Time update failed: " + error);
      });
    }

    return null;
  });

////////////////////////////////////
// Track experience like creations
exports.likeCreate = functions.firestore
  .document('experiences/{experienceId}/likeList/{userId}')
  .onCreate((change, context) => {

    const like = change.data();

    // update experience likes
    return admin.firestore().doc('experiences/' + context.params.experienceId).update({ "numOfLikes": admin.firestore.FieldValue.increment(1) })
    .then(() => {
      return admin.firestore().doc('users/' + like.creator.id + '/likeList/' + like.experience.id).set(like);
    })
    .then(() => {
      return admin.firestore().doc('users/' + like.creator.id).update({ "numberOfLikes": admin.firestore.FieldValue.increment(1) });
    })
    .then(() => {
      return notifyCreatorAboutLike(like);
    })
    .catch((error) => {
      console.error("Experience like created failed: " + error);
    });

  });

////////////////////////////////////
// Track experience deletes
exports.experienceRemove = functions.firestore
  .document('experiences/{experienceId}')
  .onDelete((change, context) => {

    const experience = change.data();

    // delete all collections too
    return admin.firestore().doc("experienceLocations/" + context.params.experienceId).delete()
    .then(() => {
      return utils.deleteCollection(admin.firestore(), "experiences/" + context.params.experienceId + "/postList", 10);
    })
    .then(() => {
      return utils.deleteCollection(admin.firestore(), "experiences/" + context.params.experienceId + "/historyList", 10);
    })
    .then(() => {
      return utils.deleteCollection(admin.firestore(), "experiences/" + context.params.experienceId + "/tipList", 10);
    })
    .then(() => {
      return utils.deleteCollection(admin.firestore(), "experiences/" + context.params.experienceId + "/timeList", 10);
    })
    .then(() => {
      return utils.deleteCollection(admin.firestore(), "experiences/" + context.params.experienceId + "/likeList", 10);
    })
    .then(() => {
      let promiseStack = [];
      experience.images.forEach((image) => {
        const promise = admin.storage().bucket().file(image.path).delete();
        promiseStack.push(promise);
        if (image.previewPath !== null && image.previewPath !== undefined) {
          const promise = admin.storage().bucket().file(image.previewPath).delete();
          promiseStack.push(promise);
        }
      });
      return Promise.all(promiseStack);
    })
    .then(() => {
      return admin.firestore().doc('users/' + experience.creator.id).update({ "numberOfDesigned": admin.firestore.FieldValue.increment(-1) });
    })
    .catch((error) => {
      console.error("Experience remove cleanup failed: " + error);
    });
  });

////////////////////////////////////
// Track post deletes
exports.postRemove = functions.firestore
  .document('experiences/{experienceId}/postList/{postId}')
  .onDelete((change, context) => {

    const post = change.data();
    return admin.firestore().doc("users/" + post.creator.id + "/posts/" + context.params.postId).delete()
    .then(() => {
      return utils.deleteCollection(admin.firestore(), "experiences/" + context.params.experienceId + "/postList/" + context.params.postId + "/requestList", 10);
    })
    .then(() => {
      return updateExperiencePostExpiration(context.params.experienceId);
    })
    .then(() => {
      let update = {};
      update["postLocations." + post.creator.id] = admin.firestore.FieldValue.delete();
      return admin.firestore().doc("experiences/" + context.params.experienceId).update(update);
    })
    .catch((error) => {
      console.error("Experience post remove cleanup failed: " + error);
    });
  });

////////////////////////////////////
// Track request deletes
exports.requestRemove = functions.firestore
  .document('experiences/{experienceId}/postList/{postId}/requestList/{requestId}')
  .onDelete((change, context) => {

    const request = change.data();
    return admin.firestore().doc("users/" + request.creator.id + "/requests/" + context.params.requestId).delete();
  });

////////////////////////////////////
// Track history deletes
exports.historyRemove = functions.firestore
  .document('experiences/{experienceId}/historyList/{historyId}')
  .onDelete((change, context) => {

    // delete all collections too
    return utils.deleteCollection(admin.firestore(), "experiences/" + context.params.experienceId + "/postList/" + context.params.postId + "/messageList", 10)
    .catch((error) => {
      console.error("Experience history remove cleanup failed: " + error);
    });
  });

////////////////////////////////////
// Track time deletes
exports.timeRemove = functions.firestore
  .document('experiences/{experienceId}/timeList/{timeId}')
  .onDelete((change, context) => {

    const time = change.data();
    let promiseStack = [];
    time.chat.memberIds.forEach((memberId) => {
      const promise = admin.firestore().doc("users/" + memberId + "/times/" + context.params.timeId).delete();
      promiseStack.push(promise);
    });
    return Promise.all(promiseStack)
      .then(() => {
        return updateExperienceTimeExpiration(context.params.experienceId);
      })
      .catch((error) => {
        console.error("Experience time remove cleanup failed: " + error);
      });
  });

////////////////////////////////////
// Track chat deletes
exports.chatRemove = functions.firestore
  .document('chats/{chatId}')
  .onDelete((change, context) => {

    // delete all collections too
    return utils.deleteCollection(admin.firestore(), "chats/" + context.params.chatId + "/messageList", 10)
    .catch((error) => {
      console.error("Experience chat remove cleanup failed: " + error);
    });
  });

////////////////////////////////////
// Track chat deletes
exports.chatMessageRemove = functions.firestore
  .document('chats/{chatId}/messageList/{messageId}')
  .onDelete((change, context) => {

    const message = change.data();

    // delete all files too
    if (message.type === "video" || message.type === "photo") {

      if (message.additionalData === undefined || message.additionalData === null || message.additionalData.length < 10) {
        return null;
      }
      const additional = JSON.parse(message.additionalData);
      const media = additional.media;

      if (media === undefined || media === null) {
        return null;
      }

      let promiseStack = [];

      const path = media.path;
      if (path !== undefined && path !== null) {
        const promise = admin.storage().bucket().file(path).delete();
        promiseStack.push(promise);
      }

      const previewPath = media.previewPath;
      if (previewPath !== undefined && previewPath !== null) {
        const promise = admin.storage().bucket().file(previewPath).delete();
        promiseStack.push(promise);
      }

      return Promise.all(promiseStack)
      .catch((error) => {
        console.error("Experience time remove cleanup failed: " + error);
      });
    }

    return;
  });


////////////////////////////////////
// Track experience like deletes
exports.likeRemove = functions.firestore
  .document('experiences/{experienceId}/likeList/{userId}')
  .onDelete((change, context) => {

    const like = change.data();

    // update experience likes
    return admin.firestore().doc('experiences/' + context.params.experienceId).update({ "numOfLikes": admin.firestore.FieldValue.increment(-1) })
    .then(() => {
      return admin.firestore().doc('users/' + like.creator.id + '/likeList/' + like.experience.id).delete();
    })
    .then(() => {
      return admin.firestore().doc('users/' + like.creator.id).update({ "numberOfLikes": admin.firestore.FieldValue.increment(-1) });
    })
    .catch((error) => {
      console.error("Experience like delete failed: " + error);
    });

  });


//////////////////////////////////////////////////
//
// HTTP
//

////////////////////////////////////
// get user distance
exports.getDistance = functions.https.onCall((data, context) => {

  const from = data.from;
  const to = data.to;

  let promiseStack = [];
  let promise = admin.firestore().doc("userLocations/" + from).get();
  promiseStack.push(promise);
  promise = admin.firestore().doc("userLocations/" + to).get();
  promiseStack.push(promise);
  return Promise.all(promiseStack)
    .then((locationRefs) => {
      if (locationRefs === undefined || locationRefs === null || locationRefs.length < 2) {
        return { error: "nodata" };
      }

      const fromLocation = locationRefs[0].data().l;
      const toLocation = locationRefs[1].data().l;

      const distance = utils.getDistanceFromLatLonInKm(fromLocation.latitude, fromLocation.longitude, 
        toLocation.latitude, toLocation.longitude);

      return { distance: distance };
    })
    .catch((error) => {
      console.error("getDistance failed: " + error);
      throw new functions.https.HttpsError('error', error);
    });
  });

////////////////////////////////////
// get meeting point / group
exports.getPostMeetingPoint = functions.https.onCall((data, context) => {

  const experienceId = data.experienceId;
  const postId = data.postId;

  return admin.firestore().doc('experiences/' + experienceId + '/postList/' + postId).get()
    .then((postRef) => {
      const post = postRef.data();

      if (post.chat === undefined || post.chat === null) {
        return null;
      }

      let promiseStack = [];
      post.chat.memberIds.forEach((userId) => {
        const promise = admin.firestore().doc("userLocations/" + userId).get();
        promiseStack.push(promise);
      });
      return Promise.all(promiseStack);
    })
    .then((locationRefs) => {
      if (locationRefs === undefined || locationRefs === null || locationRefs.length < 2) {
        return { error: "nodata" };
      }

      let latitude = 0.0;
      let longitude = 0.0;

      for (var i = 0; i < locationRefs.length; i++) {
        const location = locationRefs[i].data();
        latitude = latitude + location.l.latitude;
        longitude = longitude + location.l.longitude;
      }

      let meet = {};
      meet['latitude'] = latitude / locationRefs.length;
      meet['longitude'] = longitude / locationRefs.length;

      return meet;
    })
    .catch((error) => {
      console.error("getPostMeetingPoint failed: " + error);
      throw new functions.https.HttpsError('error', JSON.stringify(error));
    });
  });

////////////////////////////////////
// get meeting point / 1on1
exports.getRequestMeetingPoint = functions.https.onCall((data, context) => {

  const experienceId = data.experienceId;
  const postId = data.postId;
  const requestId = data.requestId;

  return admin.firestore().doc('experiences/' + experienceId + '/postList/' + postId + '/requestList/' + requestId).get()
    .then((requestRef) => {
      const request = requestRef.data();

      let promiseStack = [];
      let promise = admin.firestore().doc("userLocations/" + request.creator.id).get();
      promiseStack.push(promise);
      promise = admin.firestore().doc("userLocations/" + request.post.creator.id).get();
      promiseStack.push(promise);
      return Promise.all(promiseStack);
    })
    .then((locationRefs) => {
      if (locationRefs === undefined || locationRefs === null || locationRefs.length < 2) {
        return { error: "nodata" };
      }

      let latitude = 0.0;
      let longitude = 0.0;

      for (var i = 0; i < locationRefs.length; i++) {
        const location = locationRefs[i].data();
        latitude = latitude + location.l.latitude;
        longitude = longitude + location.l.longitude;
      }

      let meet = {};
      meet['latitude'] = latitude / locationRefs.length;
      meet['longitude'] = longitude / locationRefs.length;

      return meet;
    })
    .catch((error) => {
      console.error("getPostMeetingPoint failed: " + error);
      throw new functions.https.HttpsError('error', JSON.stringify(error));
    });
  });


