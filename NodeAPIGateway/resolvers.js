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

Notices = {};

function getNoteFromHash() {};

function getNoteFromDate() {};

function getAllNotes() {};

// TODO
// take graphQL request, find id (hash) or time range specified
// send to random instance, receiving json
// return json
function getResource() {};

// TODO Optoinal
function refreshNotices() {

};

// data store with default data
// TODO db
/*const Notices = [
  {
    id: 1,
    topic: "John",
    description: "Peter",
    dateOfSubmission: new Date("2014-08-31"),
    email: "John@gmail.com",
    password: "John123",
    country: "UK"
  },
  {
    id: 2,
    topic: "Mohamed",
    description: "Tariq",
    dateOfSubmission: new Date("1981-11-24"),
    email: "tariq@gmail.com",
    password: "tariq123",
    country: "UAE"
  },
  {
    id: 3,
    topic: "Nirmal",
    description: "Kumar",
    dateOfSubmission: new Date("1991-09-02"),
    email: "nirmal@gmail.com",
    password: "nirmal123",
    country: "India"
  }
];*/

var instances = 5;

const resolvers = {
    Query: {
        Notes: () => {
            getAllNotes();
        },
        Note: (_, {
            id
        }) => {
            getNoteFromHash(id);
        }
    },
    Mutation: {
        createNote: (root, args) => {

        },
        deleteNote: (root, args) => {

        },
        updateNote: (root, args) => {

        },
        GQDate
    }
};

/*const resolvers = {
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
            Notices[index].email = args.email;
            Notices[index].password = args.password;
            Notices[index].country = args.country;
            // get next Notice id
            const nextId =
                Notices.reduce((id, Notice) => {
                    return Math.max(id, Notice.id);
                }, -1) + 1;
            const newNotice = {
                id: nextId,
                topic: args.topic,
                description: args.description,
                dateOfSubmission: args.dateOfSubmission
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
            Notices[index].dateOfSubmission = args.dateOfSubmission;
            return Notices[index];
        }
    },
    GQDate
};*/

module.exports.Resolvers = resolvers;