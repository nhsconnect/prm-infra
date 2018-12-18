// 'use strict';

// exports.handler = function (event, context, callback) {
//     var response = {
//         statusCode: 200,
//         headers: {
//             'Content-Type': 'text/xml; charset=utf-8',
//         },
//         body: "Hey Vini!",
//     };
//     callback(null, response);
// };

// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Set the region
AWS.config.update({region: 'REGION'});

// Create DynamoDB service object
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

var params = {
    RequestItems: {
        "PROCESS_STORAGE": [
            {
                PutRequest: {
                    Item: {
                        "KEY": { "PROCESS_ID": "PROCESS_PAYLOAD" },
                        1234: "PROCESSING"
                    }
                }
            }
        ]
    }
};

exports.handler = async (event) => {
    ddb.batchWriteItem(params, function(err, data) {
        if (err) {
            console.log("Error", err);
        } else {
            console.log("Success", data);
        }
    });

    const responseBody = {
        "uuid": "12344"
    };

    const response = {
        "statusCode": 200,
        "headers": {
            "my_header": "my_value"
        },
        "body": JSON.stringify(responseBody),
        "isBase64Encoded": false
    };
    return response;
};