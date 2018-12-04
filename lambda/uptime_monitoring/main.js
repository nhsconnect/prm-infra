// const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest
// const Http = new XMLHttpRequest();
// const url='https://vk070b7rgc.execute-api.eu-west-2.amazonaws.com/test';

// // Http.onreadystatechange=(e)=>{
// //     console.log(Http.responseText);
// // }
// exports.handler = (event, context) => {
//     console.log("I'm here!!");
//     Http.open("POST", url);
//     Http.send();
// };

const http = require('https');

exports.handler = async (event, context) => {

    return new Promise((resolve, reject) => {
        const options = {
            host: 'vk070b7rgc.execute-api.eu-west-2.amazonaws.com',
            path: '/test',
            // port: 8000,
            method: 'POST'
        };

        const req = http.request(options, (res) => {
            console.log("res = " + res.statusCode)
            console.log("location = " + res.headers.location)
            resolve('Success');
        });

        req.on('error', (e) => {
            reject(e.message);
        });

        // send the request
        req.write('');
        req.end();
    });
};