import sys
import requests

filename = sys.argv[1]
file = open(filename, 'r')

messageContent = file.read()
headers = {'Content-Type': 'application/xml'}
response = requests.post('https://r5w3yuys2l.execute-api.eu-west-2.amazonaws.com/test', messageContent, headers)

print(response.status_code)
print(response.text)

