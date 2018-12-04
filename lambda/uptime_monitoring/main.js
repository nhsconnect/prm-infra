const http = require('https');
const URL = require('url');

exports.handler = async (event, context) => {
    const myURL = new URL.URL(process.env.url);

    return new Promise((resolve, reject) => {
        const options = {
            host: myURL.host,
            path: '/test',
            // port: 8000,
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
};