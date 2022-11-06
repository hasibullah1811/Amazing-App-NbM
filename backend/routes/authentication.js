const express = require('express');
const router = express.Router();
const fs = require('firebase-admin');
const {getAuth, signInWithEmailAndPassword, GoogleAuthProvider, signInWithCredential} = require("firebase/auth");

router.post('/signIn',async  (req, res) => {

  const credential = GoogleAuthProvider.credential(req.body.id_token,req.body.access_token);

  // Sign in with credential from the Google user.
  const auth = getAuth();
  signInWithCredential(auth, credential).catch((error) => {
    // Handle Errors here.
    const errorCode = error.code;
    const errorMessage = error.message;
    // The email of the user's account used.
    const email = error.customData.email;
    // The AuthCredential type that was used.
    const credential = GoogleAuthProvider.credentialFromError(error);
    // ...
    res.status(400).send(errorMessage);
  }).then(async (UserCred) => {
     if(UserCred!=null){
      const db = fs.firestore(); 
      await db.collection("Users").doc(UserCred.user.uid).get().then(async user => {
        if(user.exists){
         res.status(200).send(user.data());
        }else{
          await db.collection("Users").doc(UserCred.user.uid).set({
            "uid": UserCred.user.uid,
            "email": UserCred.user.email,
            "displayName": UserCred.user.displayName,
            "pic": ""
          });
          res.status(200).send({
            "uid": UserCred.user.uid,
            "email": UserCred.user.email,
            "displayName": UserCred.user.displayName,
            "pic": ""
          });
        }
     });
     }
  });
});

module.exports = router;