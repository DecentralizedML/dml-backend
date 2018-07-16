require('dotenv').config();

const express = require('express');
const bodyParser = require('body-parser');
const routes = require('./routes');

const database = require('./mongo');

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

database().then((db) => {
  routes(app, db);

  const server = app.listen(port, () => {
    /* eslint-disable-next-line no-console */
    console.log('Server running on port', server.address().port);
  });
});
