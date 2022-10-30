const express = require('express');
const cors = require('cors');

const app = express();

const { sequelize } = require('./models');

const mainRoutes = require('./routes/mainRoutes');

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
// app.use(cors());
// app.use(express.static("build"));
// app.use(express.json());

app.use('/', mainRoutes)
// app.get('/', (req,res)=>{
//     res.send('hello world')
// })

module.exports = app;
