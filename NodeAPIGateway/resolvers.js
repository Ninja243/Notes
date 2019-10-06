const {
    GraphQLScalarType
} = require("graphql");

function convertDate(inputFormat) {
    function pad(s) {
        return s < 10 ? "0" + s : s;
    }
    var d = new Date(inputFormat);
    return [pad(d.getDate()), pad(d.getMonth()), d.getFullYear()].join("/");
}

// Define Date scalar type.

const GQDate = new GraphQLScalarType({
    name: "GQDate",
    description: "Date type",
    parseValue(value) {
        // value comes from the client
        return value; // sent to resolvers
    },
    serialize(value) {
        // value comes from resolvers
        return value; // sent to the client
    },
    parseLiteral(ast) {
        // value comes from the client
        return new Date(ast.value); // sent to resolvers
    }
});

// data store with default data
/*const Notices = [
  {
    id: 1,
    topic: "Johan",
    description: "Peter",
    dateOfCreation: new Date("2014-08-31"),
    email: "johan@gmail.com",
    password: "johan123",
    country: "UK"
  },
  {
    id: 2,
    topic: "Mohamed",
    description: "Tariq",
    dateOfCreation: new Date("1981-11-24"),
    email: "tariq@gmail.com",
    password: "tariq123",
    country: "UAE"
  },
  {
    id: 3,
    topic: "Nirmal",
    description: "Kumar",
    dateOfCreation: new Date("1991-09-02"),
    email: "nirmal@gmail.com",
    password: "nirmal123",
    country: "India"
  }
];*/

const resolvers = {
    Query: {
        Notices: () => Notices, // return all Notices
        Notice: (_, {
                id
            }) =>
            Notices.find(Notice => Notice.id == id) // return Notice by id
    },
    Mutation: {
        // create a new Notice
        createNotice: (root, args) => {
            // get next Notice id
            const nextId =
                Notices.reduce((id, Notice) => {
                    return Math.max(id, Notice.id);
                }, -1) + 1;
            const newNotice = {
                id: nextId,
                topic: args.topic,
                description: args.description,
                dateOfCreation: args.dateOfCreation
            };
            // add Notice to collection
            Notices.push(newNotice);
            return newNotice;
        }, // delete Notice by id
        deleteNotice: (root, args) => {
            // find index by id
            const index = Notices.findIndex(
                Notice => Notice.id == args.id
            );
            // remove Notice by index
            Notices.splice(index, 1);
        }, // update Notice
        updateNotice: (root, args) => {
            // find index by id
            const index = Notices.findIndex(
                Notice => Notice.id == args.id
            );
            Notices[index].topic = args.topic;
            Notices[index].description = args.description;
            Notices[index].dateOfCreation = args.dateOfCreation;
            return Notices[index];
        }
    },
    GQDate
};

module.exports.Resolvers = resolvers;