'use strict';

exports.handler = function (event, context, callback) {
    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/xml; charset=utf-8',
        },
        body: "Hello Vini!",
    };
    callback(null, response);
};
