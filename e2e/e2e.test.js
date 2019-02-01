const request = require("request-promise-native");
const errors = require("request-promise-native/errors");
const fs = require("fs")
const path = require("path")

const PRIVATE_KEY_DATA = process.env.PRIVATE_KEY_DATA;
const CERT_DATA = fs.readFileSync(path.resolve(__dirname, "cert.pem"))
const REQUEST_DATA = fs.readFileSync(path.resolve(__dirname, "test-request.xml"))

test("That PDS responds to a valid request", async () => {
  try {
    const options = {
      url: 'https://192.168.128.11/smsp/pds',
      cert: CERT_DATA,
      key: PRIVATE_KEY_DATA,
      body: REQUEST_DATA,
      headers: {
        "Content-Type": "text/xml",
        "SOAPAction": "urn:nhs-itk:services:201005:getNHSNumber-v1-0"
      }
    };

    await request.post(options);
  } catch (e) {
    expect(e.statusCode).toBe(200);
    expect(e instanceof errors.StatusCodeError).toBeTruthy();
  }
});
