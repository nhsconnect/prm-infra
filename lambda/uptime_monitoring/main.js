const http = require('https');
const URL = require('url');
const xmlData = '<?xml version="1.0" encoding="UTF-8"?>'

exports.handler = async (event, context) => {
    const myURL = new URL.URL(process.env.url);
    const path = process.env.stage;

    const response1 = new Promise((resolve, reject) => {
        const options = {
            host: myURL.host,
            path: "/dev",
            method: 'POST',
            headers: {
                'Content-Type': 'text/xml',
                'Content-Length': Buffer.byteLength(xmlData)
            }
        };

        const req = http.request(options, (res) => {
            console.log(`res ${res.statusCode}`);
            resolve('Success');
        });

        req.on('error', (e) => {
            reject(e.message);
        });

        req.write(xmlData);
        req.end();
    });

    const response2 = new Promise((resolve, reject) => {
        const options = {
            host: myURL.host,
            path: "/cde",
            method: 'POST'
        };

        const req = http.request(options, (res) => {
            console.log(`res ${res.statusCode}`);
            resolve('Success');
        });

        req.on('error', (e) => {
            reject(e.message);
        });

        req.write(xmlData);
        req.end();
    });

    return Promise.all([response1, response2]);
};