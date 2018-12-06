const request = require("request-promise-native");
const errors = require('request-promise-native/errors');



test('That PRM tells us when we use the wrong endpoint', async () => {
    expect.assertions(2);
    try {
        await request.post("https://j4dbzo021j.execute-api.eu-west-2.amazonaws.com/bleh");
    } catch (e) {
        expect(e.statusCode).toBe(403);
        expect(e instanceof errors.StatusCodeError).toBeTruthy();
    }
});

test('That PRM tells is broadly speaking, working', async () => {
    const response = await request.post("https://j4dbzo021j.execute-api.eu-west-2.amazonaws.com/test");
    expect(response.statusCode).toBe(200);
});