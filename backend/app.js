const express = require('express');
const cors = require('cors');

const app = express();

const config = require("./utils/config");
// const middleware = require("./utils/middleware");
const logger = require("./utils/logger");

const { sequelize } = require('./models');

const mainRoutes = require('./routes/mainRoutes');
const userRoutes = require('./routes/userRoutes');

const connectDB = async () => {
  try {
    console.log("Connecting to Database...");
    await sequelize.authenticate();
    // await sequelize.sync({force:true})
    console.log("Connected to Database!");
  } catch (error) {
    console.log("Failed to Connect to Database!", error.message);
  }
};

connectDB();

// /**
//  * Use all core packages
//  *
//  * CORS, Express, ExpressJSON
//  */
app.use(cors());
app.use(express.static("build"));
app.use(express.json());

app.use('/', mainRoutes)
app.use('/user', userRoutes)
// app.get('/', (req,res)=>{
//     res.send('hello world')
// })

// app.use(middleware.unknownEndpoint);

module.exports = app;
