const { async } = require("@firebase/util");
const express = require("express");
const router = express.Router();
const fs = require("firebase-admin");

router.get("/getAllImageLinks", async (req, res) => {
  try {
    const db = fs.firestore();
    const doc = db.collection("Users");

    const snapshot = await doc.get();
    const doctData = snapshot.docs.map((doc) => doc.data());
    const photoLinks = doctData.map((doc) => doc.pic);
    //   res.send(photoLinks);
    res.status(200).send(photoLinks);
  } catch (error) {
    res.status(440).send(error);
  }
});

module.exports = router;
