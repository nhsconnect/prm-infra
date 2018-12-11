'use strict';

exports.handler = function (event, context, callback) {
    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/xml; charset=utf-8',
        },
        body: "Ciao Vini!",
    };
    callback(null, response);
};
