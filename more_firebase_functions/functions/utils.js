//////////////////////////////////////////////////
//
// utils
//

function now() {
  return Math.floor(Date.now() / 1000) - 978307200;
}

exports.now = now;

function deg2rad(deg) {
  return deg * (Math.PI/180)
}

exports.deg2rad = deg2rad;

function getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
  var R = 6371000; // Radius of the earth in m
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1); 
  var a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ; 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; // Distance in m
  return d;
}

exports.getDistanceFromLatLonInKm = getDistanceFromLatLonInKm;

//////////////////////////////////////////////////
//
// cleanup utils
//

function deleteCollection(db, collectionPath, batchSize) {
  let collectionRef = db.collection(collectionPath);
  let query = collectionRef.orderBy('__name__').limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, batchSize, resolve, reject);
  });
}

exports.deleteCollection = deleteCollection;

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

exports.deleteQueryBatch = deleteQueryBatch;

//////////////////////////////////////////////////
//
// firestore utils
//

function shortUserFromUser(user) {

  let shortUser = {
    id: user.id,
    name: user.name,
    avatar: user.avatar
  };
  if (user.age !== null && user.age !== undefined) {
    shortUser['age'] = user.age;
  }
  
  return shortUser;
}

exports.shortUserFromUser_firestore = shortUserFromUser;

function shortUserFromProfile(profile) {

  let shortUser = {
    id: profile.id,
    name: profile.name,
    avatar: "--"
  };
  
  return shortUser;
}

exports.shortUserFromProfile_firestore = shortUserFromProfile;

function timeFromRequest(request) {

  var time = {
    id: request.signal.id,
    signal: request.signal,
    requester: request.sender,
    createdAt: now()
  };

  return time;
}

exports.timeFromRequest_firestore = timeFromRequest;

function shortTimeFromTime(time) {

  let shortTime = {
    id: time.id,
    signal: time.signal,
    requester: time.requester,
    createdAt: time.createdAt
  };
  if (time.endedAt !== null && time.endedAt !== undefined) {
    shortTime['endedAt'] = time.endedAt;
  }
  
  return shortTime;
}

exports.shortTimeFromTime_firestore = shortTimeFromTime;

function shortSignalFromSignal(signal) {

  const text = signal.text;
  const type = signal.type;
  const expiresAt = signal.expiresAt;
  const signalCreator = signal.creator;
  const images = signal.images;
  
  const creator = shortUserFromUser(signalCreator);

  const shortSignal = {
    text: text,
    type: type,
    expiresAt: expiresAt,
    creator: creator,
    images: images
  };

  return shortSignal;
}

exports.shortSignalFromSignal_firestore = shortSignalFromSignal;

//////////////////////////////////////////////////
//
// experience utils
//

function shortExperienceFromExperience(experience) {

  const title = experience.title;
  const text = experience.text;
  const type = experience.type;
  const experienceCreator = experience.creator;
  const images = experience.images;
  
  const creator = shortUserFromUser(experienceCreator);

  let shortExperience = {
    title: title,
    text: text,
    images: images,
    type: type,
    creator: creator,
  };
  if (experience.isVirtual !== null && experience.isVirtual !== undefined) {
    shortExperience['isVirtual'] = experience.isVirtual;
  }
  if (experience.isPrivate !== null && experience.isPrivate !== undefined) {
    shortExperience['isPrivate'] = experience.isPrivate;
  }
  if (experience.tier !== null && experience.tier !== undefined) {
    shortExperience['tier'] = experience.tier;
  }

  return shortExperience;
}

exports.shortExperienceFromExperience_firestore = shortExperienceFromExperience;

function shortPostFromPost(post) {

  const text = post.text;
  const postCreator = post.creator;
  const images = post.images;
  const experience = post.experience;
  
  const creator = shortUserFromUser(postCreator);

  let shortPost = {
    creator: creator,
    experience: experience,
    text: text,
    images: images
  };
  if (post.title !== null && post.title !== undefined) {
    shortPost['title'] = post.title;
  }
  if (post.isSilent !== null && post.isSilent !== undefined) {
    shortPost['isSilent'] = post.isSilent;
  }

  return shortPost;
}

exports.shortPostFromPost_firestore = shortPostFromPost;

function shortRequestFromRequest(request) {

  const requestCreator = request.creator;
  const post = request.post;
  
  const creator = shortUserFromUser(requestCreator);

  let shortRequest = {
    creator: creator,
    post: post
  };
  if (request.accepted !== null && request.accepted !== undefined) {
    shortRequest['accepted'] = request.accepted;
  }

  return shortRequest;
}

exports.shortRequestFromRequest_firestore = shortRequestFromRequest;



