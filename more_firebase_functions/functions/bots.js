const functions = require('firebase-functions');
const admin = require('firebase-admin');
const messaging = require('./messaging');
const utils = require('./utils');
const { GeoCollectionReference, GeoFirestore, GeoQuery, GeoQuerySnapshot } = require('geofirestore');


// GeoFirestore
const geofirestore = new GeoFirestore(admin.firestore());
const geocollection = geofirestore.collection('experienceLocations');

//////////////////////////////////////////////////
// Constants

const newYork = [40.762913, -73.979537];

const manhattan = [
  [40.706612, -74.016015],
  [40.748980, -74.007970],
  [40.875011, -73.927323],
  [40.870435, -73.911514],
  [40.837464, -73.935643],
  [40.799665, -73.931121],
  [40.781878, -73.944785],
  [40.776889, -73.942977],
  [40.742370, -73.972811],
  [40.711868, -73.977589],
  [40.708876, -73.999439],
  [40.701784, -74.011333]
];

const williamsburg = [
  [40.724326, -73.960778],
  [40.721475, -73.956088],
  [40.724548, -73.948234],
  [40.720108, -73.944404],
  [40.721791, -73.941185],
  [40.715094, -73.942286],
  [40.704812, -73.939422],
  [40.701585, -73.936839],
  [40.698392, -73.959711],
  [40.706982, -73.969093],
  [40.712979, -73.968415]
];

var percentageOfClaiming = 0.01;

const destinationRadius = 0.0217;

var postExpiration = 3600;

var numberOfBots = 1;

//////////////////////////////////////////////////
// Math

function rollDie(ratio) {
  return Math.random() <= ratio;
}

function inside(point, vs) {
  // ray-casting algorithm based on
  // http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html

  var x = point[0], y = point[1];

  var inside = false;
  for (var i = 0, j = vs.length - 1; i < vs.length; j = i++) {
    var xi = vs[i][0], yi = vs[i][1];
    var xj = vs[j][0], yj = vs[j][1];

    var intersect = ((yi > y) !== (yj > y))
        && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }

  return inside;
}

function clipToManhattan(point) {

}

function randomInPolygon(vs) {

  var minX = 0;
  var maxX = 0;
  var minY = 0;
  var maxY = 0;

  for (var i = 0; i < vs.length; i++) {
    if (minX > vs[i][0] || minX === 0) {
      minX = vs[i][0]
    }
    if (maxX < vs[i][0] || maxX === 0) {
      maxX = vs[i][0]
    }
    if (minY > vs[i][1] || minY === 0) {
      minY = vs[i][1]
    }
    if (maxY > vs[i][1] || maxY === 0) {
      maxY = vs[i][1]
    }
  }

  var x = 0;
  var y = 0;

  var deltaX = maxX - minX;
  var deltaY = maxY - minY;

  do {
    x = minX + Math.random() * deltaX;
    y = minY + Math.random() * deltaY;
  }
  while (!inside([x,y], vs));

  return [x,y];
}

function randomInCircle(point, radius) {

  var angle = Math.random()*Math.PI*2;
  var randomRadius = radius*Math.random();
  const x = point[0] + Math.cos(angle)*randomRadius;
  const y = point[1] + Math.sin(angle)*randomRadius;

  return [x,y];
}

//////////////////////////////////////////////////
// Helpers

function claimExperienceById(experienceId) {

  return admin.firestore().doc("experiences/" + experienceId)
    .get()
    .then((experienceRef) => {
  
      // error
      if (experienceRef === null || experienceRef === undefined) {
        return null;
      }

      const experience = experienceRef.data();

      // error
      if (experience === null || experience === undefined) {
        return null;
      }

      return claimExperience(experienceId, experience);
    });
}

function claimExperience(experienceId, experience) {

  // already claimed
  if (experience.postExpiresAt !== undefined && experience.postExpiresAt !== null && experience.postExpiresAt > 0) {
    return null;
  }

  // roll the die
  if (!rollDie(percentageOfClaiming)) {
    return null;
  }

  // check schedule
  const now = utils.now();
  const date = new Date();

  if (experience.schedule !== null && experience.schedule !== undefined) {

    if (experience.start > now || experience.end < now) {
      return null
    }

    const day = date.getDay();
    let today = null;
    switch(day) {
      case 0: //Sunday
        today = experience.schedule.sunday;
        break;
      case 1: 
        today = experience.schedule.monday;
        break;
      case 2: 
        today = experience.schedule.tuesday;
        break;
      case 3: 
        today = experience.schedule.wednesday;
        break;
      case 4: 
        today = experience.schedule.thursday;
        break;
      case 5: 
        today = experience.schedule.friday;
        break;
      case 6: 
        today = experience.schedule.saturday;
        break;
      default:
        break;
    }

    // no schedule - not available
    if (today === null || today === undefined) {
      return null;
    }

    // seconds in day
    const secs = date.getSeconds() + (60 * (date.getMinutes() + (60 * date.getHours())));

    // not inside day schedule
    if (today.start > secs || today.end < secs) {
      return null;
    }
  }

  // Schedule is fine !!!
  var location = newYork;

  // get the location
  if (experience.destination !== null && experience.destination !== undefined) {
    var i = 0;
    do {
      location = randomInCircle([experience.destination.latitude, experience.destination.longitude], destinationRadius);
      i = i + 1;
    } 
    while (!inside(location, manhattan) && i < 6);
  } else {
    location = randomInPolygon(manhattan);
  }

  var shortExperience = utils.shortExperienceFromExperience_firestore(experience);
  shortExperience["id"] = experienceId;

  // create post
  var post = {
    createdAt: now,
    expiresAt: now + postExpiration,
    // creator: User,
    experience: shortExperience,
    title: experience.title,
    text: experience.text,
    images: [],
    started: false,
    location: new admin.firestore.GeoPoint(location[0], location[1])
  };

  // find a random bot user
  let randomUser = Math.floor(1 + Math.random() * numberOfBots);
  return admin.firestore().collection("users")
    .where("isBot", "==", true)
    .where("randomId", "==", randomUser)
    .get()
    .then((users) => {
      if (users === null || users === undefined || users.empty) return null;

      const userRef = users.docs[0];
      const userId = userRef.id;
      const user = userRef.data();

      var userData = {
        id: userId,
        name: user.firstName,
      };

      return admin.firestore().collection("users/" + userId + "/imageList")
        .get()
        .then((images) => {
          if (images === null || images === undefined) return null;

          if (!images.empty) {
            userData["avatar"] = images.docs[0].data().url;
          }
          post["creator"] = userData;

          console.log("Bot post created:\n" + JSON.stringify(post));

          return admin.firestore().collection("experiences/" + experienceId + "/postList")
            .add(post);
        });
    });
}

//////////////////////////////////////////////////
//
// scheduled jobs
//

function claimBot() {
  const newYorkGeo = new admin.firestore.GeoPoint(newYork[0], newYork[1]);
  return geocollection.near({ center: newYorkGeo, radius: 8 }).get()
  .then((value) => {
    let promiseStack = [];
    for (var i = 0; i < value.docs.length; i++) {
      const experienceId = value.docs[i].id;

      const promise = claimExperienceById(experienceId);
      promiseStack.push(promise);
    }
    return Promise.all(promiseStack);
  })
  .then(() => {
    return admin.firestore().collection("experiences")
      .where("anywhere", "==", true)
      .get();
  })
  .then((experiences) => {
    if (experiences === null || experiences === undefined) return null;

    let promiseStack = [];
    experiences.forEach((child) => {
      const experienceId = child.id;
      const experience = child.data();

      const promise = claimExperience(experienceId, experience);
      promiseStack.push(promise);
    });
    return Promise.all(promiseStack);
  });
}

// experience bot claim -> 5 miles around Time Square
exports.fivemin_job = functions.pubsub
  .topic('fivemin-tick')
  .onPublish((message) => {

    console.log("Bot tick");

    return admin.firestore().doc("settings/bots")
      .get()
      .then((botsRef) => {
        const bots = botsRef.data();

        if (bots.enabled === true) {

          if (bots.percentageOfClaiming !== null && bots.percentageOfClaiming !== undefined) {
            percentageOfClaiming = bots.percentageOfClaiming;
          }

          if (bots.numberOfBots !== null && bots.numberOfBots !== undefined) {
            numberOfBots = bots.numberOfBots;
          }

          if (bots.postExpiration !== null && bots.postExpiration !== undefined) {
            postExpiration = bots.postExpiration;
          }

          return claimBot();
        } else {
          return null;
        }
      })
  });


