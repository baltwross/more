const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

const messaging = require('./messaging');
const more_firestore = require('./firestore');
const more_experience = require('./experience');
const more_twilio = require('./twilio');
const more_bots = require('./bots');
const more_video = require('./video');

//////////////////////////////////////////////////
//
// Firestore
//

// CRON
exports.fivemin_job_firestore = more_firestore.fivemin_job;

// exports.fivemin2_job = more_firestore.fivemin2_job;

exports.tenmin_job_firestore = more_firestore.tenmin_job;

exports.hourly_job_firestore = more_firestore.hourly_job;

exports.hourly1_4_job_firestore = more_firestore.hourly1_4_job;

exports.hourly1_2_job_firestore = more_firestore.hourly1_2_job;

exports.hourly3_4_job_firestore = more_firestore.hourly3_4_job;

exports.daily_job_firestore = more_firestore.daily_job;

// users
exports.userCreate_firestore = more_firestore.userCreate;

exports.userRemove_firestore = more_firestore.userRemove;

exports.userImageRemove_firestore = more_firestore.userImageRemove;

// tracking active signals
exports.signalCreate_firestore = more_firestore.signalCreate;

exports.signalRequest_firestore = more_firestore.signalRequest;
  
exports.signalResponse_firestore = more_firestore.signalResponse;
 
exports.signalRemove_firestore = more_firestore.signalRemove;

// tracking claimables
exports.claimableRemove_firestore = more_firestore.claimableRemove;

// tracking active times
exports.timeReview_firestore = more_firestore.timeReview;

exports.timeChange_firestore = more_firestore.timeChange;
  
exports.timeRemove_firestore = more_firestore.timeRemove;

// tracking messages
exports.message_firestore = more_firestore.message;

////////////////////////////////////
// experiences

// experience post list cleanup -> removes posts if they are expired
exports.fivemin_job_firestore_experience = more_experience.fivemin_job;

exports.tenmin_job_firestore_experience = more_experience.tenmin_job;

exports.hourly_job_firestore_experience = more_experience.hourly_job;

exports.hourly1_4_job_firestore_experience = more_experience.hourly1_4_job;

exports.hourly1_2_job_firestore_experience = more_experience.hourly1_2_job;

exports.hourly3_4_job_firestore_experience = more_experience.hourly3_4_job;

exports.daily_job_firestore_experience = more_experience.daily_job;

// tracking experiences
exports.experienceCreate_firestore_experience = more_experience.experienceCreate;

exports.postCreate_firestore_experience = more_experience.postCreate;

exports.requestCreate_firestore_experience = more_experience.requestCreate;

exports.requestUpdate_firestore_experience = more_experience.requestUpdate;

exports.postUpdate_firestore_experience = more_experience.postUpdate;

exports.timeCreate_firestore_experience = more_experience.timeCreate;

exports.timeUpdate_firestore_experience = more_experience.timeUpdate;

exports.likeCreate_firestore_experience = more_experience.likeCreate;

// cleanup
exports.experienceRemove_firestore_experience = more_experience.experienceRemove;

exports.postRemove_firestore_experience = more_experience.postRemove;

exports.requestRemove_firestore_experience = more_experience.requestRemove;

exports.historyRemove_firestore_experience = more_experience.historyRemove;

exports.timeRemove_firestore_experience = more_experience.timeRemove;

exports.chatRemove_firestore_experience = more_experience.chatRemove;

exports.chatMessageRemove_firestore_experience = more_experience.chatMessageRemove;

exports.likeRemove_firestore_experience = more_experience.likeRemove;

// http
exports.getDistance = more_experience.getDistance;
 
exports.getPostMeetingPoint = more_experience.getPostMeetingPoint;

exports.getRequestMeetingPoint = more_experience.getRequestMeetingPoint;

//////////////////////////////////////////////////
//
// Video
//

exports.fivemin_job_video = more_video.fivemin_job;

//////////////////////////////////////////////////
//
// Twilio
//

exports.getTwilioToken = more_twilio.getTwilioToken;

//////////////////////////////////////////////////
//
// Bots
//

// CRON
exports.fivemin_job_bots = more_bots.fivemin_job;
