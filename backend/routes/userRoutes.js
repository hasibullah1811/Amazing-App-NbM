const { response } = require("../app");

const router = require("express").Router();

//get user details
router.get("/user/:userID", (request, response) => {});

//create user 
router.post("/user", (request, response) => {});

//get user photoUrl
router.get("/user/photo/:userID", (request, response) => {});
