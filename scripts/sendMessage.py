import sys
import requests

filename = sys.argv[1]
file = open(filename, 'r')

messageContent = file.read()
headers = {'Content-Type': 'application/xml'}
response = requests.post('https://qcq3n9xx8c.execute-api.eu-west-2.amazonaws.com/test', messageContent, headers).text

print(response)

