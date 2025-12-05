import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// 範例 Cloud Function
export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.json({message: "Hello from Firebase!"});
});



