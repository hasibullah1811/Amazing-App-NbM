const { async } = require('@firebase/util');
const express = require('express');
const router = express.Router();
const fs = require('firebase-admin');
const Multer = require('multer');

const {uploadImageToStorage} = require('../functions/uploadImageToStorage');
const multer = Multer({
  storage: Multer.memoryStorage(),
  fileFilter: (req, file, cb) => {
    if (file.mimetype == "image/png" || file.mimetype == "image/jpg" || file.mimetype == "image/jpeg") {
      cb(null, true);
    } else {
      cb(null, false);
      return cb(new Error('Only .png, .jpg and .jpeg format allowed!'));
    }
  },
  limits: {
    fileSize: 2 * 1024 * 1024, // no larger than 2mb, you can change as needed.
    files: 1, 
  },
});
const upload = multer.single('file');


router.post('/uploadPic/:uid',async (req, res) => {
  const db = fs.firestore();

  upload(req, res, function (err) {
    if (err) {
      return res.status(400).send({ error: err.message })
    }
    else{
        let file = req.file;
        if (file) 
        {
             uploadImageToStorage(file, `${req.params.uid}`).then( async (fileLink) => {
              //sets the data:  
              data = {
                //changes will be made here: 
                "pic" : fileLink,
              };
              //updates database:
              await db.collection("Users").doc(req.params.uid).update(data);
              //sends response:
              res.status(200).send({
                "pic" : fileLink
              });
              }).catch((error) => {
                return res.status(400).send({ error: error.message })
              });
          }
          else{
                return res.status(400).send({ error: "where is the file bruh?" })
          }
    }
  });
});

module.exports = router;
