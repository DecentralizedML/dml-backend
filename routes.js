module.exports = (app, mongo) => {
  app.get('/', (req, res) => {
    console.log(mongo.database.databaseName);

    res.status(200).send('Welcome to our restful API');
  });
};
