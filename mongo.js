const MongoClient = require('mongodb').MongoClient;

const url = process.env.MONGODB_URL;

module.exports = async () => {
  const database = await MongoClient.connect(url, { useNewUrlParser: true }).then((client) => {
    return client.db();
  });

  return { database };
};
