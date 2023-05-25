const functions = require('firebase-functions');
const admin = require('firebase-admin');
const AccessToken = require('twilio').jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;

// Used when generating any kind of Access Token
const twilioAccountSid = 'ACfb749e875513a487a56bc8094d8e882a';
const twilioApiKey = 'SK7d94c4fbacd693a6bebdeebeaedd6767';
const twilioApiSecret = 'OBQY9zlk49JjtCWq7wt6uiF53b06xTZ3';

////////////////////////////////////
// Twilio AUTH

exports.getTwilioToken = functions.https.onCall((data, context) => {

  const userId = data.userId;

  // Create an access token which we will sign and return to the client,
  // containing the grant we just created
  const token = new AccessToken(twilioAccountSid, twilioApiKey, twilioApiSecret);
  token.identity = userId;

  // Create a Video grant which enables a client to use Video 
  const videoGrant = new VideoGrant({ });

  // Add the grant to the token
  token.addGrant(videoGrant);

  const jwt = token.toJwt();

  console.log('Twilio token: ' + jwt);

  return { "token": jwt };
});
