import sys
import requests
import json

filename = sys.argv[1]


file = open(filename, 'r')
messageContent = file.read()
response = requests.get('https://qcq3n9xx8c.execute-api.eu-west-2.amazonaws.com/test', messageContent)

print(response.status_code)

# if response.status_code == 200:
#     return json.loads(response.content.decode('utf-8'))
# else:
#     return None

