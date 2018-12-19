// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Set the region
AWS.config.update({region: 'eu-west-2'});

// Create the DynamoDB service object
ddb = new AWS.DynamoDB({apiVersion: '2012-10-08'});

var params = {
    AttributeDefinitions: [
        {
            AttributeName: 'PROCESS_ID',
            AttributeType: 'S'
        }
    ],
    KeySchema: [
        {
            AttributeName: 'PROCESS_ID',
            KeyType: 'HASH'
        }
    ],
    ProvisionedThroughput: {
        ReadCapacityUnits: 1,
        WriteCapacityUnits: 1
    },
    TableName: 'PROCESS_STORAGE',
    StreamSpecification: {
        StreamEnabled: false
    }
};

// Call DynamoDB to create the table
ddb.createTable(params, function(err, data) {
    if (err) {
        console.log("Error", err);
    } else {
        console.log("Success", data);
    }
});