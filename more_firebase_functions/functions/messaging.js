const admin = require('firebase-admin');

exports.sendMessage = function(userId, title, text, params, priority = '5') {

	return admin.database().ref("/users/" + userId + "/registrationToken")
	.once('value')
  .then((token) => {
	  
    if (token.exists()) {

      const deviceToken = token.val();    

      var message = {
        notification: {
          title: title,
          body: text,
        },
        apns: {
          headers: {
            'apns-priority': priority,
          },
          payload: {
            aps: {
              alert: {
                title: title,
                body: text,
              },
              sound: 'default',
              badge: 1, 
            },
          },
        },
        token: deviceToken, 
      };

      for (var key in params) {
      	message.apns.payload[key] = params[key]
      }

      return admin.messaging().send(message);
    }

    return null; 
  })
  .then((response) => {
    if (response === null) {
      console.log('Message not sent. UserID ' + userId + ' has not registrationToken');
    } else {
      console.log('Successfully sent message:', response);
    }
    return null;
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
};

//////////////////////////////////////////////////
//
// Firestore messaging utils
//

exports.sendMessage_firestore = function(userId, title, text, params, priority = '5') {

  return admin.firestore().doc("users/" + userId)
  .get()
  .then((userRef) => {
    
    let user = userRef.data();
    let deviceToken = user.registrationToken;
    if (deviceToken !== null && deviceToken !== undefined) {

      var message = {
        notification: {
          title: title,
          body: text,
        },
        apns: {
          headers: {
          	'apns-push-type': 'alert',
            'apns-priority': priority,
          },
          payload: {
            aps: {
              alert: {
                title: title,
                body: text,
              },
              sound: 'default',
              badge: 1, 
            },
          },
        },
        token: deviceToken, 
      };

      for (var key in params) {
        message.apns.payload[key] = params[key]
      }

      return admin.messaging().send(message);
    }

    return null; 
  })
  .then((response) => {
    if (response === null) {
      console.log('Message not sent. UserID ' + userId + ' has not registrationToken');
    } else {
      console.log('Successfully sent message:', response);
    }
    return null;
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
};

exports.receivedReviewMessage_firestore = function(review) {

  const title = reviewerName + " Reviewed Your Time";
  const text = "Leave your review to see what they‌ wrote!";
  var params = {};
  params['type'] = 'newReview';
  params['timeId'] = review.time.id;
  params['reviewId'] = review.id;

  let userId = review.time.signal.creator.id;
  if (userId === review.creator.id) {
    userId = review.time.requester.id;
  }

  var msg = {
    userId: userId,
    title: title,
    text: text,
    params: params
  };

  return msg;
};

exports.readReviewsMessage_firestore = function(review) {

  const title = "Read " + review.creator.name + "'s Review";
  let comment = review.comment;
  if (comment.length > 100) {
    comment = comment.substr(0, 97) + "...";
  }
  const text = review.creator.name + "said:\n" + comment;
  var params = {};
  params['type'] = 'newReview';
  params['timeId'] = review.time.id;
  params['reviewId'] = review.id;

  let userId = review.time.signal.creator.id;
  if (userId === review.creator.id) {
    userId = review.time.requester.id;
  }

  var msg = {
    userId: userId,
    title: title,
    text: text,
    params: params
  };

  return msg;
};


exports.arrivedMessage_firestore = function(userId, time) {

  let receiverId = time.signal.creator.id;
  let senderName = time.requester.name;
  if (receiverId === userId) {
    receiverId = review.time.requester.id;
    senderName = time.signal.creator.name;
  }

  const title = senderName + " has arrived!";
  let text = "Great news! " + senderName  + " just arrived at the meeting point.";
  if (time.requesterState === "arrived") {
    text = senderName + " is nearby! Confirm in the app when you find each other.";
  }

  var params = {};
  params['timeId'] = time.id;
  params['userId'] = userId;
  params['type'] = 'timeArrived';

  var msg = {
    userId: receiverId,
    title: title,
    text: text,
    params: params
  };

  return msg;
};


exports.metMessage_firestore = function(userId, time) {

  let receiverId = time.signal.creator.id;
  let senderName = time.requester.name;
  if (receiverId === userId) {
    receiverId = review.time.requester.id;
    senderName = time.signal.creator.name;
  }

  const title = senderName + " says you've met!";
  const text = creatorName + " says you've found each other. Please confirm to end navigation.";

  var params = {};
  params['timeId'] = time.id;
  params['userId'] = userId;
  params['type'] = 'timeMet';

  var msg = {
    userId: receiverId,
    title: title,
    text: text,
    params: params
  };

  return msg;
};

exports.queryMetMessage_firestore = function(userId, time) {

  let receiverId = time.signal.creator.id;
  let senderName = time.requester.name;
  if (receiverId === userId) {
    receiverId = time.requester.id;
    senderName = time.signal.creator.name;
  }

  const title = "Did You Find Each Other?";
  const text = "Please confirm you and " + senderName + " have met up.";

  var params = {};
  params['timeId'] = time.id;
  params['userId'] = userId;
  params['type'] = 'timeMet';

  var msg = {
    userId: receiverId,
    title: title,
    text: text,
    params: params
  };

  return msg;
};

exports.queryArrivedMessage_firestore = function(userId, time) {

  let receiverId = time.signal.creator.id;
  let senderName = time.requester.name;
  if (receiverId === userId) {
    receiverId = review.time.requester.id;
    senderName = time.signal.creator.name;
  }
  const title = "Did you arrive?";
  const text = "Let " + senderName + " know you're at the meeting point.";
  
  var params = {};
  params['timeId'] = time.id;
  params['userId'] = userId;
  params['type'] = 'timeArrived';

  var msg = {
    userId: receiverId,
    title: title,
    text: text,
    params: params
  };

  return msg;
};



exports.cancelledMessage_firestore = function(userId, time) {

  let receiverId = time.signal.creator.id;
  let senderName = time.requester.name;
  let message = time.requesterCancelMessage;
  if (receiverId === userId) {
    receiverId = time.requester.id;
    senderName = time.signal.creator.name;
    message = time.creatorCancelMessage;
  }

  const title = senderName + " has cancelled!";
  let text = senderName + " has cancelled the Time.";
  if (message !== null && message !== undefined) {
    text = message;
  }

  var params = {};
  params['timeId'] = time.id;
  params['userId'] = userId;
  params['type'] = 'timeCancelled';

  var msg = {
    userId: receiverId,
    title: title,
    text: text,
    params: params
  };

  return msg;
};
