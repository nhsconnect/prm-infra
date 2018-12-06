const http = require('https');
const URL = require('url');

exports.handler = async (event, context) => {
    const myURL = new URL.URL(process.env.url);
    const path = process.env.stage;

    const response1 = new Promise((resolve, reject) => {
        const options = {
            host: myURL.host,
            path: "/test",
            method: 'POST'
        };

        const req = http.request(options, (res) => {
            console.log(`res ${res.statusCode}`);
            resolve('Success');
        });

        req.on('error', (e) => {
            reject(e.message);
        });

        req.write('');
        req.end();
    });

    const response2 = new Promise((resolve, reject) => {
        const options = {
            host: myURL.host,
            path: "/abc",
            method: 'POST'
        };

        const req = http.request(options, (res) => {
            console.log(`res ${res.statusCode}`);
            resolve('Success');
        });

        req.on('error', (e) => {
            reject(e.message);
        });

        req.write('');
        req.end();
    });

    return Promise.all([response1, response2]);
};