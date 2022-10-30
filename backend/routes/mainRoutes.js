const router = require("express").Router();

/**
 * Routes
 *
 * prefix: /
 */

// Read

router.get("/", async (request, response) => {
    response.send('Welcome to the Amazing app');
});

module.exports = router;
