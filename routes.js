const appRouter = (app) => {
  app.get('/', (req, res) => {
    res.status(200).send('Welcome to our restful API');
  });
};

module.exports = appRouter;
