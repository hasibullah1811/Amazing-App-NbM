
const chalk = require("chalk");

const info = (...params) => {
  if (process.env.NODE_ENV !== "test") console.log(chalk.blue(...params));
};

const success = (...params) => {
  if (process.env.NODE_ENV !== "test") console.log(chalk.green(...params));
};

const error = (...params) => {
  if (process.env.NODE_ENV !== "test") console.log(chalk.red(...params));
};

module.exports = {
  info,
  error,
  success,
};
