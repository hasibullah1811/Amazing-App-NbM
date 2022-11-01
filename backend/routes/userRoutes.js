// const { response } = require("../app");

const router = require("express").Router();
const { v4 } = require("uuid");
// import { v4 as uuidv4 } from "uuid";

const Models = require("../models");

//get user details
router.get("/:userID", async (request, response) => {
    const userId = request.params.userID;
  try {
    const userProfileId = await Models.User.findOne({userId: userId});
    // return userProfileId;
    return response
      .status(200)
      .send({ status: "ok", result: { imageUrl: userProfileId.imageUrl } });
  } catch (error) {
    return response
      .status(500)
      .json({ status: "Failed", result: "user cannot be added" });
  }
});

//create user
router.post("/", async (request, response) => {
  const body = request.body;
  console.log(v4());
  try {
    const user = Models.User.create({
      name: body.name,
      imageUrl: body.imageUrl,
      id: v4(),
    });
    return response.status(200).send({ status: "ok", result: { user } });
  } catch (error) {
    return response
      .status(500)
      .json({ status: "Failed", result: "user cannot be added" });
  }
});

//get user photoUrl
router.get("/photo/:userID", async (request, response) => {
  const userId = request.params.userID;
  try {
    const userProfileId = await Models.User.findOne({userId: userId});
    // return userProfileId;
    return response
      .status(200)
      .send({ status: "ok", result: { imageUrl: userProfileId.imageUrl } });
  } catch (error) {
    return response
      .status(500)
      .json({ status: "Failed", result: "user cannot be added" });
  }
});

module.exports = router;
