const request = require("request-promise-native")
const fs = require("fs")
const path = require("path")

const PRIVATE_KEY_DATA = process.env.PRIVATE_KEY_DATA;
const CERT_DATA = fs.readFileSync(path.resolve(__dirname, "cert.pem"))
const CA_DATA = fs.readFileSync(path.resolve(__dirname, "ca.pem"))
const REQUEST_DATA = fs.readFileSync(path.resolve(__dirname, "test-request.xml"))

jest.setTimeout(8000);

test("That PDS responds to a valid request", async () => {
  console.log("Cert: " + CERT_DATA.toString('utf8'))
  console.log("Private Key Len: " + PRIVATE_KEY_DATA.length)

  const options = {    
    method: 'POST',
    url: 'https://msg.opentest.hscic.gov.uk/smsp/pds',
    agentOptions: {
      cert: CERT_DATA,
      key: PRIVATE_KEY_DATA,
      ca: CA_DATA,
    },
    body: REQUEST_DATA,
    headers: {
      "Content-Type": "text/xml",
      "SOAPAction": "urn:nhs-itk:services:201005:getNHSNumber-v1-0"
    },
    timeout: 5000
  };

  await request.post(options)
});