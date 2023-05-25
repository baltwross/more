const functions = require('firebase-functions');
const admin = require('firebase-admin');
const messaging = require('./messaging');
const utils = require('./utils');

//////////////////////////////////////////////////
//
// Data utils
//

function countNumberOfGoings(time) {
  const creatorId = time.signal.creator.id;
  const requesterId = time.requester.id;

  const creatorState = time.creatorState;
  const requesterState = time.requesterState;

  if ((creatorState === "met" || creatorState === "closed") && 
      (requesterState === "met" || requesterState === "closed")) {

    return admin.firestore().doc('users/' + creatorId).update({ "numberOfGoings": Firestore.FieldValue.increment(1) })
    .then(() => {
      return admin.firestore().doc('users/' + requesterId).update({ "numberOfGoings": Firestore.FieldValue.increment(1) })
    })
  }

  return null;
}

function deleteCollection(db, collectionPath, batchSize) {
  let collectionRef = db.collection(collectionPath);
  let query = collectionRef.orderBy('__name__').limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, batchSize, resolve, reject);
  });
}

function deleteQueryBatch(db, query, batchSize, resolve, reject) {
  query.get()
    .then((snapshot) => {
      // When there are no documents left, we are done
      if (snapshot.size === 0) {
        return 0;
      }

      // Delete documents in a batch
      let batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      return batch.commit().then(() => {
        return snapshot.size;
      });
    }).then((numDeleted) => {
      if (numDeleted === 0) {
        resolve();
        return null;
      }

      // Recurse on the next process tick, to avoid
      // exploding the stack.
      process.nextTick(() => {
        deleteQueryBatch(db, query, batchSize, resolve, reject);
      });
      return null;
    })
    .catch(reject);
}

function getChat(userA, userB) {

  return admin.firestore()
  .collection("chats")
  .where("memberIds." + userA, "==", true)
  .where("memberIds." + userB, "==", true)
  .get()
  .then((chats) => {
    let selectedChatRef = undefined;
    chats.forEach((chatRef) => {
      const chat = chatRef.data();
      if (Object.keys(chat.memberIds).length === 2) {
        selectedChatRef = chatRef;
      }
    });
    return selectedChatRef;
  })
}

function sendMessageToChat(userA, userB, message) {
  return getChat(userA, userB)
  .then((chatRef) => {
    // insert request message
    if (chatRef !== null && chatRef !== undefined) {
      return admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(message);
    }

    return null;
  })
}

//////////////////////////////////////////////////
//
// CRON
//

// Signal list cleanup -> removes signals if they are expired (expired 30 mins ago)
exports.fivemin_job = functions.pubsub
  .topic('fivemin-tick')
  .onPublish((message) => {

    const thirtyMinsAgo = utils.now() - 1800;

    return admin.firestore().collection("signals")
    .where("expiresAt", "<", thirtyMinsAgo)
    .get()
    .then((signals) => {

      if (signals === null || signals === undefined) return null;

      return signals.forEach((child) => {
        const signalId = child.id;
        admin.firestore().doc("signals/" + signalId).delete();
      });
    });
  });

/*
exports.fivemin2_job = functions.pubsub
  .topic('fivemin2-tick')
  .onPublish((message) => {

    let nowTime = utils.now();
    return admin.firestore().collection("claimables").orderByChild("expiresAt").endAt(now)
    .once('value')
    .then((signals) => {

      if (!signals.exists()) return null;

      return signals.forEach((child) => {
        const signalId = child.key;
        admin.firestore().doc("claimables/" + signalId).remove();
      });
    });
  });
*/

// Time list cleanup -> closes times if they are expired
exports.tenmin_job = functions.pubsub
  .topic('tenmin-tick')
  .onPublish((message) => {

    const nowTime = utils.now();
    const tenMinsAgo = nowTime - 600;

    return admin.firestore().collection("times")
    .where("endedAt", ">=", tenMinsAgo)
    .where("endedAt", "<", nowTime)
    .select("creatorState", "requesterState")
    .get()
    .then((times) => {

      if (times === null ||times === undefined) return null;

      return times.forEach((timeRef) => {

        const timeId = timeRef.id;
        const time = timeRef.data();
        const requesterState = time.requesterState;
        const creatorState = time.creatorState;

        if (creatorState !== "met" && creatorState !== "cancelled" && creatorState !== "closed") {
          admin.firestore().doc("times/" + timeId).update({ "creatorState": "closed" });
        }
        if (requesterState !== "met" && requesterState !== "cancelled" && requesterState !== "closed") {
          admin.firestore().doc("times/" + timeId).update({ "requesterState": "closed" });
        }

      });
    });
  });

// Time list review reminder -> sends PN 
exports.hourly_job = functions.pubsub
  .topic('hourly-tick')
  .onPublish((message) => {
    
    const nowTime = utils.now();
    const threeHoursAgo = nowTime - 10800;
    const fourHoursAgo = nowTime - 14400;

    return admin.firestore().collection("times")
    .where("endedAt", ">=", fourHoursAgo)
    .where("endedAt", "<", threeHoursAgo)
    .select("creatorState", "requesterState", "reviewList", "reviewState", "signal.creator", "signal.text", "requester.id")
    .get()
    .then((times) => {

      if (times === null ||times === undefined) return null;

      return times.forEach((timeRef) => {
          
        const timeId = timeRef.id;
        const time = timeRef.data();
        const creatorId = time.signal.creator.id;
        const timeText = time.signal.text;
        const requesterId = time.requester.id;

        const creatorState = time.creatorState;
        const requesterState = time.requesterState;

        if (creatorState === "cancelled" || requesterState === "cancelled") {

          return admin.firestore().doc("times/" + timeId)
          .get()
          .then((oldTime) => {
            let promiseStack = [];
            let promise = admin.firestore().doc("cancelled/" + timeId).set(time);
            promiseStack.push(promise);
            promise = admin.firestore().doc("times/" + timeId).delete();
            promiseStack.push(promise);
            return Promise.all(promiseStack);
          });
        }

        // PN to remind about reviews
        var creatorReviewed = false;
        var requesterReviewed = false;

        let promiseStack = [];

        time.reviewList.forEach((child) => {
          const writterId = child.creator.id;
          if (writterId === creatorId) {
            creatorReviewed = true;
          } else if (writterId === requesterId) {
            requesterReviewed = true;
          }

          let title = "";
          let text = "";
          let params = {};
          params['type'] = 'timeReviewReminder';
          params['timeId'] = timeId;

          if (!creatorReviewed) {
            const requesterName = child.requester.name;
            title = "Review your Time with " + requesterName;
            text = "How was " + timeText;
            const promise = messaging.sendMessage_firestore(creatorId, title, text, params, '10');
            promiseStack.push(promise);
          }

          if (!requesterReviewed) {
            const creatorName = child.signal.creator.name;
            title = "Review your Time with " + creatorName;
            text = "How was " + timeText;
            const promise = messaging.sendMessage_firestore(requesterId, title, text, params, '10');
            promiseStack.push(promise);
          }      
        });
        return Promise.all(promiseStack);
      });
    });
  });

// Time list review reminder -> sends PN 
exports.hourly1_4_job = functions.pubsub
  .topic('hourly1-4-tick')
  .onPublish((message) => {
    
    const nowTime = utils.now();
    const dayAgo = nowTime - 86400;
    const dayAndHourAgo = nowTime - 90000;

    return admin.firestore().collection("times")
    .where("endedAt", "<=", dayAgo)
    .where("endedAt", ">", dayAndHourAgo)
    .select("reviewList", "signal.creator", "signal.text", "requester.id")
    .get()
    .then((times) => {

      if (times === null ||times === undefined) return null;

      return times.forEach((timeRef) => {
        
        const timeId = timeRef.id;
        const time = timeRef.data();
        const creatorId = time.signal.creator.id;
        const timeText = time.signal.text;
        const requesterId = time.requester.id;

        return timeRef.collection("reviewList").get().then(reviews => {
          // PN to remind about reviews
          let creatorReviewed = false;
          let requesterReviewed = false;

          reviews.forEach((child) => {
            const review = child.data()
            const writterId = review.creator.id;

            if (writterId === creatorId) {
              creatorReviewed = true;
            } else if (writterId === requesterId) {
              requesterReviewed = true;
            }
          });

          const title = "Reminder: Write a Review";
          let text = "";
          let params = {};
          params['type'] = 'timeReviewReminder';
          params['timeId'] = timeId;

          let promiseStack = [];

          if (!creatorReviewed) {
            const requesterName = child.requester.name;
            text = "Loved your Time with " + requesterName + "? Review the experience while the memory is still fresh!";
            const promise = messaging.sendMessage_firestore(creatorId, title, text, params, '10');
            promiseStack.push(promise);
          }

          if (!requesterReviewed) {
            const creatorName = child.signal.creator.name;
            text = "Loved your Time with " + creatorName + "? Review the experience while the memory is still fresh!";
            const promise = messaging.sendMessage_firestore(requesterId, title, text, params, '10');
            promiseStack.push(promise);
          }

          return Promise.all(promiseStack);
        });
        
      });
    });
  });

// Time list review reminder -> sends PN 
exports.hourly1_2_job = functions.pubsub
  .topic('hourly1_2-tick')
  .onPublish((message) => {
    
    const nowTime = utils.now();
    const sixDaysAgo = nowTime - 518400;
    const sixDaysAndHourAgo = nowTime - 522000;

    return admin.firestore().collection("times")
    .where("endedAt", "<=", sixDaysAgo)
    .where("endedAt", ">", sixDaysAndHourAgo)
    .select("reviewList", "signal.creator", "signal.text", "requester")
    .get()
    .then((times) => {

      if (times === null ||times === undefined) return null;

      return times.forEach((timeRef) => {
        
        const timeId = timeRef.id;
        const time = timeRef.data();
        const creatorId = time.signal.creator.id;
        const timeText = time.signal.text;
        const requesterId = time.requester.id;
        
        // PN to remind about reviews

        return timeRef.collection("reviewList").get().then(reviews => {
          let creatorReviewed = false;
          let requesterReviewed = false;

          reviews.forEach((child) => {
            const review = child.data()
            const writterId = review.creator.id;
            if (writterId === creatorId) {
              creatorReviewed = true;
            } else if (writterId === requesterId) {
              requesterReviewed = true;
            }
          });

          const title = "Last Chance to Review";
          let text = "";
          let params = {};
          params['type'] = 'timeReviewReminder';
          params['timeId'] = timeId;

          let promiseStack = [];

          if (!creatorReviewed) {
            const requesterName = time.requester.name;
            text = "Review your Time with " + requesterName;
            const promise = messaging.sendMessage_firestore(creatorId, title, text, params, '10');
            promiseStack.push(promise);
          }

          if (!requesterReviewed) {
            const creatorName = time.signal.creator.name;
            text = "Review your Time with " + creatorName;
            const promise = messaging.sendMessage_firestore(requesterId, title, text, params, '10');
            promiseStack.push(promise);
          }

          return Promise.all(promiseStack);
        });
      });
    });
  });

exports.hourly3_4_job = functions.pubsub
  .topic('hourly3_4-tick')
  .onPublish((message) => {
    
    const nowTime = utils.now();
    const sevenDaysAgo = nowTime - 604800;

    return admin.firestore().collection("times")
    .where("endedAt", "<", sevenDaysAgo)
    .select("reviewList", "signal.creator", "signal.text", "requester")
    .get()
    .then((times) => {

      if (times === null ||times === undefined) return null;

      return times.forEach((timeRef) => {

        // ids
        const timeId = timeRef.id;
        const time = timeRef.data();
        const creatorId = time.signal.creator.id;
        const requesterId = time.requester.id;
        
        // store review in user data
        var shortTime = {
          id: time.key,
          signal: time.child('signal').val(),
          createdAt: time.child('createdAt').val(),
        };

        // reviews
        var creatorReview = {};
        var requesterReview = {};

        // notice
        var title = "";
        var text = "";
        var review = "";

        // remove time
        admin.firestore().doc("times/" + timeId).delete();

        return timeRef.collection("reviewList").get().then(reviews => {

          let promiseStack = [];

          reviews.forEach((child) => {
            const writterId = child.creator.id;
            if (writterId === creatorId) {

              creatorReview = child;

              // store review
              let proimse = admin.firestore().doc("users/" + requesterId + "/reviewList/" + timeId).set(creatorReview);
              promiseStack.push(promise);

              // notify
              title = "Read " + creatorReview.creator.name + "'s Review";
              review = creatorReview.comment;
              if (review.length > 100) {
                review = review.substr(0, 97) + "...";
              }
              text = creatorReview.creator.name + "said:\n" + review;
              params['reviewId'] = creatorReview.id;

              proimse = messaging.sendMessage_firestore(requesterId, title, text, params, '10');
              promiseStack.push(promise);

            } else if (writterId === requesterId) {

              requesterReview = child;

              // store review
              let proimse = admin.firestore().doc("users/" + creatorId + "/reviewList/" + timeId).set(requesterReview);
              promiseStack.push(promise);

              // notify
              title = "Read " + requesterReview.creator.name + "'s Review";
              review = requesterReview.comment;
              if (review.length > 100) {
                review = review.substr(0, 97) + "...";
              }
              text = requesterReview.creator.name + "said:\n" + review;
              params['reviewId'] = requesterReview.id;

              proimse = messaging.sendMessage_firestore(creatorId, title, text, params, '10');
              promiseStack.push(promise);
            }
          });

        return Promise.all(promiseStack);           
        });
      });
    });
  });

exports.daily_job = functions.pubsub
  .topic('daily-tick')
  .onPublish((message) => {
    console.log("This job is run every day!");
    return true;
  });

//////////////////////////////////////////////////
//
// users patch
//

exports.userCreate = functions.firestore
  .document('users/{userId}')
  .onCreate((change, context) => {

    // add more team chat

    const profile = change.data();

    let me = {
      id: context.params.userId,
      name: "---",
      avatar: "--"
    };
    if (profile.name !== null && profile.name !== undefined) {
      me["name"] = profile.name;
    }

    const more = {
      id: "moreteam",
      name: "More",
      avatar: "--"
    };

    let memberIds = {};
    memberIds["moreteam"] = true;
    memberIds[context.params.userId] = true;

    let chat = {
      createdAt: utils.now(),
      members: [more, me],
      memberIds: memberIds,
      typing: []
    };

    console.log("Chat: " + JSON.stringify(chat));

    return admin.firestore().collection("chats").add(chat)
    .then((chatRef) => {
      // insert request message

      console.log("Chat ID: " + chatRef.id);

      let msg = {
        createdAt: utils.now(),
        sender: more,
        type: "welcome",
        text: "https://startwithmore.wistia.com/embed/medias/v1ib3g9vxi.m3u8"
      };

      console.log("Message: " + JSON.stringify(msg));

      return admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(msg);
    })
    .then(() => {
      return admin.firestore().doc("users/" + context.params.userId).update({ "verified": true });
    })
    .catch((error) => {
      console.log("User creation failed: " + error);
    });    
  });

// User Cleanup
exports.userRemove = functions.firestore
  .document('users/{userId}')
  .onDelete((change, context) => {

    // delete all collections too
    return deleteCollection(admin.firestore(), "users/" + context.params.userId + "/imageList", 10)
    .then(() => {
      return deleteCollection(admin.firestore(), "users/" + context.params.userId + "/requests", 10);
    })
    .then(() => {
      return deleteCollection(admin.firestore(), "users/" + context.params.userId + "/signals", 10);
    })
    .then(() => {
      return deleteCollection(admin.firestore(), "users/" + context.params.userId + "/times", 10);
    })
    .then(() => {
      return deleteCollection(admin.firestore(), "users/" + context.params.userId + "/reviewList", 10);
    })
    .then(() => {
      return deleteCollection(admin.firestore(), "users/" + context.params.userId + "/likeList", 10);
    })
    .then(() => {
      // delete all chats
      const batchSize = 10;
      let query = admin.firestore().collection("chats").where("memberIds." + context.params.userId, "==", true).orderBy('createdAt').limit(batchSize);
      return new Promise((resolve, reject) => {
        deleteQueryBatch(admin.firestore(), query, batchSize, resolve, reject);
      });
    })
    .catch((error) => {
      console.log("User remove cleanup failed: " + error);
    });
  });

// Image cleanup
exports.userImageRemove = functions.firestore
  .document('users/{userId}/imageList/{imageId}')
  .onDelete((change, context) => {

    const image = change.data();

    // delete image
    return admin.storage().bucket().file(image.path).delete()
    .catch((error) => {
      console.log("Image remove cleanup failed: " + error);
    });
  });

//////////////////////////////////////////////////
//
// tracking active signals
//

// Add signal Id to tracking list of creator
exports.signalCreate = functions.firestore
  .document('signals/{signalId}')
  .onCreate((change, context) => {

    const signal = change.data();
    const shortSignal = utils.shortSignalFromSignal_firestore(signal);

    console.log("Short signal: " + JSON.stringify(shortSignal));
    console.log("Context: " + JSON.stringify(context));

    return admin.firestore().doc("users/" + shortSignal.creator.id + "/signals/" + context.params.signalId).set(shortSignal)
    .catch((error) => {
      console.log("Signal create failed: " + error);
    });
  });

// Add request Id to tracking list of requester
exports.signalRequest = functions.firestore
  .document('signals/{signalId}/requestList/{requestId}')
  .onCreate((change, context) => {

    const request = change.data();
    const creatorId = request.signal.creator.id; 
    const senderId = request.sender.id;
    const senderName = request.sender.name;

    return admin.firestore()
    .doc("users/" + senderId + "/requests/" + context.params.requestId)
    .set(request)
    .then(() => {
      // create chat if necessary

      return admin.firestore()
      .collection("chats")
      .where("memberIds." + creatorId, "==", true)
      .where("memberIds." + senderId, "==", true)
      .get()
    })
    .then((chats) => {
      let create = true;
      let selectedChatRef = undefined;
      chats.forEach((chatRef) => {
        const chat = chatRef.data();
        if (Object.keys(chat.memberIds).length === 2) {
          create = false;
          selectedChatRef = chatRef;
        }
      });
      if (create) {
        let memberIds = {};
        memberIds[creatorId] = true;
        memberIds[senderId] = true;
        let chat = {
          createdAt: utils.now(),
          members: [request.signal.creator, request.sender],
          memberIds: memberIds,
          typing: []
        };
        return admin.firestore().collection("chats").add(chat);
      }
      return selectedChatRef;
    })
    /*
    .then((chatRef) => {
      // Anything here?
    })
    */
    .then((chatRef) => {
      // insert request message

      let msg = {
        createdAt: utils.now(),
        sender: request.sender,
        type: "request",
        text: request.signal.text
      };

      let promiseStack = [];
      let promise = admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(msg);
      promiseStack.push(promise);

      // insert user request message
      if (request.message !== null && request.message !== undefined) {
        let msg = {
          createdAt: utils.now() + 1,
          sender: request.sender,
          type: "text",
          text: request.message
        };
        promise = admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(msg);
        promiseStack.push(promise);
      }
      
      return Promise.all(promiseStack);
    })
    .then((chatRef) => {
      // insert request message

      let msg = {
        createdAt: utils.now(),
        sender: request.sender,
        type: "request",
        text: request.signal.text
      };

      return admin.firestore().collection("chats/" + chatRef.id + "/messageList").add(msg);
    })
    .then(() => {
      // Send message

      let params = {};
      params['type'] = 'newRequest';
      params['requestId'] = context.params.requestId;
      params['signalId'] = context.params.signalId;
      params['senderId'] = senderId;

      const userId = request.signal.creator.id;
      const title = 'New Time Request';
      const msgText = senderName + ' is requesting a Time with you!';

      return messaging.sendMessage_firestore(userId, title, msgText, params, '10')
    })  
    .catch((error) => {
      console.log("Signal request read failed: " + error);
    });

  });

// Track signal response
exports.signalResponse = functions.firestore
  .document('signals/{signalId}/requestList/{requestId}')
  .onUpdate((change, context) => {

    const requestId = change.after.id;
    const request = change.after.data();

    if (request.accepted === false) {
      // removing the request from tracking
      return admin.firestore().doc("users/" + request.sender.id + "/requests/" + requestId).delete()
      .then(() => {
        // sending message in the chat
        let msg = {
          createdAt: utils.now(),
          sender: request.signal.creator,
          type: "expired",
          text: request.signal.text
        };
        return sendMessageToChat(request.signal.creator.id, request.sender.id, msg)
      })
      .catch((error) => {
        console.log("Signal response read failed: " + error);
      });
    }

    if (request.accepted !== true) {
      return null;
    }

    var params = {};
    params['type'] = 'newResponse';
    params['requestId'] = context.params.requestId;
    params['signalId'] = context.params.signalId;

    const title = 'Request accepted';

    const time = utils.timeFromRequest_firestore(request);
    const shortTime = utils.shortTimeFromTime_firestore(time);

    // 1.) create time
    return admin.firestore().doc("times/" + context.params.signalId).set(time)
    .then(() => {
      // 2.) delete signal
      return admin.firestore().doc("signals/" + context.params.signalId).delete()
    })
    .then(() => {
      // 3.) add tracking for time to creator
      return admin.firestore().doc("users/" + time.signal.creator.id + "/times/" + time.signal.id).set(shortTime);
    })
    .then(() => {
      // 4.) add tracking for time to requester
      return admin.firestore().doc("users/" + time.requester.id + "/times/" + time.signal.id).set(shortTime);
    })
    .then(() => {
      // 5.) close all time requests posted by creator
      return admin.firestore().collection("users/" + time.signal.creator.id + "/requests")
      .select("signal.id", "sender.id")
      .get()
    })
    .then((requests) => {
      return requests.forEach((requestRef) => {
        const req = requestRef.data();
        if (req.signal.id !== time.id) {
          return admin.firestore().doc("users/" + request.sender.id + "/requests/" + requestRef.id).update({ "accepted": false });
        }
        return null;
      });
    })
    .then(() => {
      // 6.) close all time requests posted by requester
      return admin.firestore().collection("users/" + time.requester.id + "/requests")
      .select("signal.id", "sender.id")
      .get()
    })
    .then((requests) => {
      return requests.forEach((requestRef) => {
        const req = requestRef.data();
        if (req.signal.id !== time.id) {
          return admin.firestore().doc("users/" + request.sender.id + "/requests/" + requestRef.id).update({ "accepted": false });
        }
        return null;
      });
    })
    .then(() => {
      // 7.) close all signals posted by creator
      return admin.firestore().collection("users/" + time.signal.creator.id + "/signals")
      .select("id")
      .get()
    })
    .then((signals) => {
      return signals.forEach((signalRef) => {
        if (signalRef.id !== time.id) {
          return admin.firestore().doc("signals/" + signalRef.id).delete();
        }
        return null;
      });
    })
    .then(() => {
      // 8.) close all signals posted by requester
      return admin.firestore().collection("users/" + time.requester.id + "/signals")
      .select("id")
      .get()
    })
    .then((signals) => {
      return signals.forEach((signalRef) => {
        if (signalRef.id !== time.id) {
          return admin.firestore().doc("signals/" + signalRef.id).delete();
        }
        return null;
      });
    })
    .then(() => {

      // Notification
      const userId = time.requester.id;
      const text = time.signal.creator.name + ' accepted your Time request!';

      return messaging.sendMessage_firestore(userId, title, text, params, '10');
    })
    .then(() => {
      // sending message in the chat
      let msg = {
        createdAt: utils.now(),
        sender: request.signal.creator,
        type: "accepted",
        text: request.signal.text
      };
      return sendMessageToChat(time.signal.creator.id, time.requester.id, msg)
    })
    .catch((error) => {
      console.log("Signal response read failed: " + error);
    });

  });

// Signal cleanup
exports.signalRemove = functions.firestore
  .document('signals/{signalId}')
  .onDelete((change, context) => {

    const signal = change.data();

    // delete location
    return admin.firestore().doc("signalLocations/" + context.params.signalId).delete()
    .then(() => {
      // delete from creator list
      return admin.firestore().doc("users/" + signal.creator.id + "/signals/" + context.params.signalId).delete();
    })
    .then(() => {
      // delete from requester lists
      return change.ref.collection("requests").get().then((requests) => {
        let promiseStack = [];
        requests.forEach((requestRef) => {
          const requestId = requestRef.id;
          const requesterId = request.sender.id;
          const promise = admin.firebase().doc("users/" + requesterId + "/requests/" + requestId).delete();
          promiseStack.push(promise);
        });
        return Promise.all(promiseStack);
      });
    })
    .then(() => {
      // delete images only if time is not created
      return admin.firestore().doc("times/" + context.params.signalId).get()
    })
    .then((timeRef) => {
      if (!timeRef.exists && signal.manageImages === true) {
        let promiseStack = [];
        signal.images.forEach((image) => {
          const promise = admin.storage().bucket().file(image.path).delete();
          promiseStack.push(promise);
        });
        return Promise.all(promiseStack);
      }
      return null;
    })
    .then(() => {
      // delete sub collection
      return deleteCollection(admin.firestore(), "signals/" + context.params.signalId + "/requestList", 10)
    })
    .catch((error) => {
      console.log("Signal remove cleanup failed: " + error);
    });
  });

//////////////////////////////////////////////////
//
// tracking claimables
//

// Claimable cleanup
exports.claimableRemove = functions.firestore
  .document('claimables/{signalId}')
  .onDelete((change, context) => {

    const signal = change.data();

    // delete from creator list
    return admin.firestore().doc("users/" + signal.creator.id + "/claimables/" + context.params.signalId).delete()
    .then(() => {
      // delete images
      let promiseStack = [];
      signal.images.forEach((image) => {
        const promise = admin.storage().bucket().file(image.path).delete();
        promiseStack.push(promise);
      });
      return Promise.all(promiseStack);
    })
    .catch((error) => {
      console.log("Claimable remove cleanup failed: " + error);
    });
  });

//////////////////////////////////////////////////
//
// tracking active times
//

// Review created
exports.timeReview = functions.firestore
  .document('times/{timeId}/reviewList/{reviewId}')
  .onCreate((change, context) => {

    const newReview = change.data();
    const reviewerId = newReview.creator.id;
    const reviewerName = newReview.creator.name;
    const creatorId = newReview.time.signal.creator.id;
    const requesterId = newReview.time.requester.id;

    var params = {};
    params['type'] = 'newReview';
    params['timeId'] = context.params.timeId;

    return change.parent
    .get()
    .then((reviews) => {

      var creatorReviewed = false;
      var requesterReviewed = false;      
      var creatorReview = {};
      var requesterReview = {};

      reviews.forEach(reviewRef => {
        const review = reviewRef.data();
        const writterId = review.creator.id;
        if (writterId === creatorId) {
          creatorReviewed = true;
          creatorReview = review;
        }
        if (writterId === requesterId) {
          requesterReviewed = true;
          requesterReview = review;
        }
      });

      var title = "";
      var text = "";
      var review = "";

      var promiseStack = [];

      if (creatorReviewed && requesterReviewed) {

        // add reviews
        let promise = admin.firestore().doc("users/" + creatorId + "/reviewList/" + context.params.timeId).set(requesterReview);
        promiseStack.push(promise);
        promise = admin.firestore().doc("users/" + requesterId + "/reviewList/" + context.params.timeId).set(creatorReview);
        promiseStack.push(promise);

        // remove time
        promise = admin.firestore().doc("times/" + context.params.timeId).delete();
        promiseStack.push(promise);

        // TODO: -- save time for history?

        // notify requester
        const requesterMsg = messaging.readReviewsMessage_firestore(creatorReview);
        promise = messaging.sendMessage_firestore(requesterMsg.userId, requesterMsg.title, requesterMsg.text, requesterMsg.params, '10');
        promiseStack.push(promise);

        // notify crator
        const creatorMsg = messaging.readReviewsMessage_firestore(requesterReview);
        promise = messaging.sendMessage_firestore(creatorMsg.userId, creatorMsg.title, creatorMsg.text, creatorMsg.params, '10');
        promiseStack.push(promise);

      } else {
        const msg = messaging.receivedReviewMessage_firestore(newReview);
        const promise = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);
      }

      return Promise.all(promiseStack);
    })
    .catch((error) => {
      console.log("Time review read failed: " + error);
    });

  });

// time changes - rethink
exports.timeChange = functions.firestore
  .document('times/{timeId}')
  .onUpdate((change, context) => {

    if (!change.after.exists) {
      return null;
    }

    const oldTime = change.before.data();
    const time = change.after.data();

    // 1.) Check states

    const creatorState = time.creatorState;
    const requesterState = time.requesterState;

    // Creator state changed
    if (creatorState !== null && creatorState !== undefined && oldTime.creatorState !== creatorState) {

      if (creatorState === "met" || creatorState === "closed") {
        countNumberOfGoings(time);
      }

      if (creatorState === "arrived") {
        let promiseStack = [];

        // end time
        let promise = admin.firestore().doc("times/" + context.params.timeId).update({ "endedAt": utils.now() + 900 });
        promiseStack.push(promise);

        const msg = messaging.arrivedMessage_firestore(time.signal.creator.id, time);
        promise = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change creator arrived failed: " + error);
        });
      }

      if (creatorState === "met") {
        let promiseStack = [];

        //  end time if necessary
        let endTime = utils.now();
        if (requesterState !== "met" && requesterState !== "cancelled" && requesterState !== "closed") {
          endTime = utils.now() + 900;
        }
        if (endedAt === undefined || endedAt === null || endedAt > endTime) {
          const promise = admin.firestore().doc("times/" + context.params.timeId).update({ "endedAt": endTime });
          promiseStack.push(promise);
        }


        const msg = messaging.metMessage_firestore(time.signal.creator.id, time);
        const promise = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);

        // sending message in the chat
        if (requesterState === "met") {
          let msg = {
            createdAt: utils.now(),
            sender: request.signal.creator,
            type: "met",
            text: request.signal.text
          };
          const promise = sendMessageToChat(time.signal.creator.id, time.requester.id, msg);
          promiseStack.push(promise);
        }

        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change creator met failed: " + error);
        });
      }

      if (creatorState === "cancelled") {
        let promiseStack = [];

        // end time
        let promise = admin.firestore().doc("times/" + context.params.timeId).update({ "endedAt": utils.now() });
        promiseStack.push(promise);

        const msg = messaging.cancelledMessage_firestore(time.signal.creator.id, time);
        promise = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);
        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change creator cancelled failed: " + error);
        });
      }

      return null;

    // Requester state changed
    } else if (requesterState !== null && requesterState !== undefined && oldTime.requesterState !== requesterState) {

      let promiseStack = [];

      if (requesterState === "met" || requesterState === "closed") {
        const promise = countNumberOfGoings(time);
        promiseStack.push(promise);
      }

      if (requesterState === "arrived") {
        // end time
        let promise = admin.firestore().doc("times/" + context.params.timeId).update({ "endedAt": utils.now() + 900 });
        promiseStack.push(promise);

        const msg = messaging.arrivedMessage_firestore(time.requester.id, time);
        promiseStack = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);
        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change requester arrived failed: " + error);
        });
      }

      if (requesterState === "met") {

        //  end time if necessary
        let endTime = utils.now();
        if (creatorState !== "met" && creatorState !== "cancelled" && creatorState !== "closed") {
          endTime = utils.now() + 900;
        }
        if (endedAt === undefined || endedAt === null || endedAt > endTime) {
          const promise = admin.firestore().doc("times/" + context.params.timeId).update({ "endedAt": endTime });
          promiseStack.push(promise);
        }

        const msg = messaging.metMessage_firestore(time.requester.id, time);
        const promise = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);

        // sending message in the chat
        if (creatorState === "met") {
          let msg = {
            createdAt: utils.now(),
            sender: request.signal.creator,
            type: "met",
            text: request.signal.text
          };
          const promise = sendMessageToChat(time.signal.creator.id, time.requester.id, msg);
          promiseStack.push(promise);
        }

        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change requester met failed: " + error);
        });
      }

      if (requesterState === "cancelled") {
        // end time
        let promise = admin.firestore().doc("times/" + context.params.timeId).update({ "endedAt": utils.now() });
        promiseStack.push(promise);

        const msg = messaging.cancelledMessage_firestore(time.requester.id, time);
        promise = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);
        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change requester cancelled failed: " + error);
        });
      }

      return null;
    }

    // 2.) Check locations
    const creatorLocation = time.creatorLocation;
    const requesterLocation = time.requesterLocation;
    const meet = time.meeting;
  
    // location changed
    if ((creatorLocation !== null && creatorLocation !== undefined && oldTime.creatorLocation !== creatorLocation) ||
      (requesterLocation !== null && requesterLocation !== undefined && oldTime.requesterLocation !== requesterLocation)) {

      if (creatorState === "queryMet" || creatorState === "met" || creatorState === "closed" ||
        requesterState === "queryMet" || requesterState === "met" || requesterState === "closed") {
        return null;
      }

      if (requesterLocation !== undefined && requesterLocation !== null && 
        creatorLocation !== null && creatorLocation !== undefined &&
        utils.getDistanceFromLatLonInKm(creatorLocation.latitude, creatorLocation.longitude, 
        requesterLocation.latitude, requesterLocation.longitude) < 15) {

        let promiseStack = [];

        let promise = admin.firestore().doc("times/" + context.params.timeId).update({ "creatorState": "queryMet" });
        promiseStack.push(promise);
        promise = admin.firestore().doc("times/" + context.params.timeId).update({ "requesterState": "queryMet" });
        promiseStack.push(promise);

        const creatorMsg = messaging.queryMetMessage_firestore(time.signal.creator.id, time);
        promise = messaging.sendMessage_firestore(creatorMsg.userId, creatorMsg.title, creatorMsg.text, creatorMsg.params, '10');
        promiseStack.push(promise);

        const requesterMsg = messaging.queryMetMessage_firestore(time.requester.id, time);
        promise = messaging.sendMessage_firestore(requesterMsg.userId, requesterMsg.title, requesterMsg.text, requesterMsg.params, '10');
        promiseStack.push(promise);

        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change location => queryMet failed: " + error);
        });
      }

      if (meet === undefined || meet === null) {
        return null;
      }

      if (creatorState !== "queryArrived" && creatorState !== "arrived" &&
        utils.getDistanceFromLatLonInKm(creatorLocation.latitude, creatorLocation.longitude, 
        meet.latitude, meet.longitude) < 15) {
        
        let promiseStack = [];

        let promise = admin.firestore().doc("times/" + context.params.timeId).update({ "creatorState": "queryArrived" });
        promiseStack.push(promise);

        if (requesterState === "queryArrived" || requesterState === "arrived") {
          promise = admin.firestore().doc("times/" + context.params.timeId).update({ "arrivedExpiresAt": utils.now() + 1800 });
          promiseStack.push(promise);
        }

        const msg = messaging.queryMetMessage_firestore(time.signal.creator.id, time);
        promise =  messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);

        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change creator location => queryArrived failed: " + error);
        });
      }

      if (requesterState !== "queryArrived" && requesterState !== "arrived" &&
        utils.getDistanceFromLatLonInKm(requesterLocation.latitude, requesterLocation.longitude, 
        meet.latitude, meet.longitude) < 15) {

        let promiseStack = [];

        let promise = admin.firestore().doc("times/" + context.params.timeId).update({ "requesterState": "queryArrived" });
        promiseStack.push(promise);

        if (requesterState === "queryArrived" || requesterState === "arrived") {
          promise = admin.firestore().doc("times/" + context.params.timeId).update({  "arrivedExpiresAt": utils.now() + 1800 });
          promiseStack.push(promise);
        }

        const msg = messaging.queryMetMessage_firestore(time.requester.id, time);
        promise = messaging.sendMessage_firestore(msg.userId, msg.title, msg.text, msg.params, '10');
        promiseStack.push(promise);

        return Promise.all(promiseStack)
        .catch((error) => {
          console.log("Time change requester location => queryArrived failed: " + error);
        });
      }  
    }

    return null;
  });

// Time Cleanup
exports.timeRemove = functions.firestore
  .document('times/{timeId}')
  .onDelete((change, context) => {

    const time = change.data();
    const creatorId = time.signal.creator.id;
    const requesterId = time.requester.id;

    // delete from creator list      
    return admin.firestore().doc("users/" + creatorId + "/times/" + context.params.timeId).delete()
    .then(() => {
      // delete from requestors lists
      return admin.firestore().doc("users/" + requesterId + "/times/" + context.params.timeId).delete();
    })
    .then(() => {
      // delete images
      let promiseStack = [];
      time.signal.images.forEach((image) => {
        const promise = admin.storage().bucket().file(image.path).delete();
        promiseStack.push(promise);
      });
      return Promise.all(promiseStack);
    })
    .then(() => {
      // delete sub collection
      return deleteCollection(admin.firestore(), "times/" + context.params.timeId + "/reviews", 10);
    })
    .catch((error) => {
      console.log("Time remove cleanup failed: " + error);
    });
  });

//////////////////////////////////////////////////
//
// tracking messages
//

// Message Push Notification
exports.message = functions.firestore
  .document('chats/{chatId}/messageList/{messageId}')
  .onCreate((change, context) => {

    const message = change.data();
    const senderId = message.sender.id;
    const senderName = message.sender.name;

    if (message.type !== "text" && message.type !== "photo" && message.type !== "video" && message.type !== "startCall" && message.type !== "joined") {
      return null;
    }

    var params = {};
    params['type'] = 'newMessage';
    params['chatId'] = context.params.chatId;
    params['messageId'] = context.params.messageId;

    const title = senderName;
    const text = message.text;

    const chat = change.ref.parent.parent;
    return chat.get().then((chatRef) => {

      let promiseStack = [];
      
      const chatData = chatRef.data();

      let keys = Object.keys(chatData.memberIds);
      for(var i = 0; i < keys.length; i++) {
        const userId = keys[i];
        if (userId !== senderId) {
          const promise = messaging.sendMessage_firestore(userId, title, text, params, '10');
          promiseStack.push(promise);
        }
      }

      return Promise.all(promiseStack);
    })
    .catch((error) => {
      console.log("Chat message read failed: " + error);
    });
  });

