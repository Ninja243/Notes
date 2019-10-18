/** */
const schema = `
# declare custom scalars for date as GQDate
scalar GQDate

# Notice type
type Notice {
    id: ID!
    topic: String
    description: String
    dateOfSubmission: GQDate
}
#implementations of READ in the CRUD operations
type Query {
    # Return a Notice by id
    Notice(id: ID!): Notice
    # Return a Notice by Topic
    #Notice(topic: String): Notice
    # Return a Notice by Description
    #Notice(description: String): Notice
    # Return a Notice by date
    #Notice(dateOfSubmission: GQDate): Notice
    # Return all Notices
    Notices(limit: Int): [Notice]
}
#implementations of CREATE, UPDATE, DELETE in the CRUD operations
type Mutation {
    # Create a Notice
    createNotice (topic: String,description: String, dateOfSubmission: GQDate): Notice
    # Update a Notice
    updateNotice (id: ID!, topic: String,description: String, dateOfSubmission: GQDate): Notice
    # Delete a Notice
    deleteNotice(id: ID!): Notice
}
`;

module.exports.Schema = schema;