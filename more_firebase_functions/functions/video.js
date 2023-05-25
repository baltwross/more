const functions = require('firebase-functions');
const admin = require('firebase-admin');
const utils = require('./utils');

//////////////////////////////////////////////////
//
// scheduled jobs
//

// remove chats with ended video calls
exports.fivemin_job = functions.pubsub
  .topic('fivemin-tick')
  .onPublish((message) => {

    const nowTime = utils.now();
    const oneMinAgo = nowTime - 60;

    return admin.firestore().collection("chats")
    .where("videoCall.tick", "<", oneMinAgo)
    .get()
    .then((chats) => {

      if (chats === null || chats === undefined) return null;

      let promiseStack = [];
      chats.forEach((child) => {
        const chatId = child.id;
        let promise = admin.firestore().doc("chats/" + chatId).update({"videoCall": admin.firestore.FieldValue.delete()});
        promiseStack.push(promise);
      });
      return Promise.all(promiseStack);
    });
  });

