const request = require("request-promise-native")
const fs = require("fs")
const path = require("path")

const PRIVATE_KEY_DATA = process.env.PRIVATE_KEY_DATA;
const CERT_DATA = fs.readFileSync(path.resolve(__dirname, "cert.pem"))
const REQUEST_DATA = fs.readFileSync(path.resolve(__dirname, "test-request.xml"))

jest.setTimeout(30000);

test("That PDS responds to a valid request", async () => {
  const options = {    
    method: 'POST',
    url: 'https://192.168.128.11/smsp/pds',
    agentOptions: {
      cert: CERT_DATA,
      key: PRIVATE_KEY_DATA,
    },
    body: REQUEST_DATA,
    headers: {
      "Content-Type": "text/xml",
      "SOAPAction": "urn:nhs-itk:services:201005:getNHSNumber-v1-0"
    },
    timeout: 20000
  };

  await request.post(options)
});