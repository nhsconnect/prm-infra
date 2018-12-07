const Url = require("url");
const request = require("request-promise-native");
const errors = require('request-promise-native/errors');

const PRM_URL = new Url.URL(process.env.PRM_ENDPOINT);

console.log(PRM_URL)

test('That PRM tells us when we use the wrong endpoint', async () => {
    expect.assertions(2);
    try {
        await request.post(`${PRM_URL.origin}/bleh`);
    } catch (e) {
        expect(e.statusCode).toBe(403);
        expect(e instanceof errors.StatusCodeError).toBeTruthy();
    }
});

test.only('That PRM tells us that it is, broadly speaking, working', async () => {
    const response = await request.post(`${PRM_URL.origin}/test`);
    expect(response.statusCode).toBe(200);
});