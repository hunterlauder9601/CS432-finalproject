import json
from cryptography.fernet import Fernet
from getpass import getpass
import base64

#This file enables the web user to login to the harveyv server and the sqlplus server

filename="creds.JSON"
sendFile="c.JSON"
keyFile="key.key"

#Used for file encryption, only the creds file that stays on the local computer is encrypted
def createKey():
	key=Fernet.generate_key()
	with open(keyFile, 'wb') as file:
		file.write(key)
def getKey():
	try:
		with open(keyFile,'rb') as file:
			key = file.read()
		return key
	except:
		createKey()
		return getKey()

def encrypt():
	with open(filename, 'rb') as f:
		data=f.read()
	fernet = Fernet(getKey())
	encrypted=fernet.encrypt(data)
	with open(filename,'wb') as file:
		file.write(encrypted)
def decrypt():
	fernet = Fernet(getKey())
	with open(filename, 'rb') as f:
		enc_data = f.read()
	d=json.loads(fernet.decrypt(enc_data))
	return d
#Creates 2 creds files, one for harveyv & one for sqlplus
def login(usr, passw, opass):
	d = {"user": usr, "pass": passw}
	data=json.dumps(d)
	d2=json.dumps({"user": usr, "pass": opass})
	with open(filename, 'w') as f:
		f.write(data)
	with open(sendFile, 'w') as f:
		f.write(d2)
	encrypt()
#Used to confirm existence of the encryption key
def checkKey():
	try:
		open(keyFile)
		return True
	except:
		return False
#Used to confirm existence of the creds file
def checkCreds():
	try:
		open(filename)
		open(sendFile)
		return True
	except:	
		return False
#Gets user input credentials and sends to login() or uses stored creds if they exist
def main():
	if checkCreds():
		return decrypt()
	else:
		u=input("Username: ")
		print("Harveyv Password:")
		p=getpass()
		print("Acad111 Password:")
		op=getpass()
		login(u, p, op)
		return main()
