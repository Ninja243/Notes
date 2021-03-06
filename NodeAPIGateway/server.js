const express = require("express");
const cors = require("cors");
const graphqlHTTP = require("express-graphql");
const {
  makeExecutableSchema
} = require("graphql-tools");

const typeDefs = require("./schema").Schema;
const resolvers = require("./resolvers").Resolvers;

const schema = makeExecutableSchema({
  typeDefs,
  resolvers,
  logger: {
    log: e => console.log(e)
  }
});

var app = express();

app.use(cors());

app.use(function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

app.get('/', function (req, res) {
  res.sendFile('default.html', {
    root: __dirname + "/"
  });
});

var instances = 0;

app.get('/getInstanceNumber', function (req, res) {
  instances = instances + 1;
  res.send(instances);
});

app.get('/app.js', function (req, res) {
  res.sendFile('app.js', {
    root: __dirname + "/"
  });
});

app.use(
  "/graphql",
  graphqlHTTP(request => ({
    schema: schema,
    graphiql: true
  }))
);

app.listen(4004);

console.log("Running a GraphQL API server at http://localhost:4004/graphql");