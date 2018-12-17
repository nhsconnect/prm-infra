const Url = require("url");
const request = require("request-promise-native");
const errors = require("request-promise-native/errors");

const PRM_URL = new Url.URL(process.env.PRM_ENDPOINT);

test("That PRM tells us when we use the wrong endpoint", async () => {
  expect.assertions(2);
  try {
    await request.post(`${PRM_URL.origin}/bleh`);
  } catch (e) {
    expect(e.statusCode).toBe(403);
    expect(e instanceof errors.StatusCodeError).toBeTruthy();
  }
});

test("That PRM tells us that it is, broadly speaking, working", async () => {
  const response = await request.post(`${PRM_URL.origin}/test`, {
    resolveWithFullResponse: true
  });
  expect(response.statusCode).toBe(200);
});

test("That we get an ack back from the request with a unique identifier", async () => {
  const response = await request.post(`${PRM_URL.origin}/send`, {
    resolveWithFullResponse: true
  });
  expect(response.statusCode).toBe(200);
  const { uuid } = JSON.parse(response.body)
  expect(uuid).toBeDefined();

  // wait 1 sec

  const response2 = await request.get(`${PRM_URL.origin}/result?uuid=${uuid}`, {
    resolveWithFullResponse: true
  });
  expect(response2.statusCode).toBe(200);
  const { status2 } = JSON.parse(response2.body)
  expect(status2).toBe("PROCESSING");

  // wait 1 sec

  const response3 = await request.get(`${PRM_URL.origin}/result?uuid=${uuid}`, {
    resolveWithFullResponse: true
  });
  expect(response3.statusCode).toBe(200);
  const { status3 } = JSON.parse(response3.body)
  expect(status3).toBe("COMPLETED");
});
