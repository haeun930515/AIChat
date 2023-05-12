const functions = require("firebase-functions");
const admin = require("firebase-admin");

var serviceAccount = require("./copyui-82583-firebase-adminsdk-pdcyb-fa3b07fa23.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://copyui-82583-default-rtdb.firebaseio.com"
});
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
exports.createCustomToken = functions.https.onRequest( async (request, response) => {
    const user = request.body;

    const uid = `kakao:${user.uid}`;
    const updateParams = {
        displayName:user.displayName,
    };
    try{
        await admin.auth().updateUser(uid, updateParams);
    }catch(e){
        updateParams["uid"] = uid;
        await admin.auth().createUser(updateParams);
    }

    const token = await admin.auth().createCustomToken(uid);
    response.send(token);
});
