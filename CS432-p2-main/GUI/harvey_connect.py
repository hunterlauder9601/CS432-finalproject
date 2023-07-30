import paramiko
from scp import SCPClient
import time
import json
import login
import os

#This file is used to enable the Web Interface to connect with the JDBC code on the harveyv server
#	by running commands and sending/receiving files

#Used to get the SSH client for running commands on the harveyv server
def getSSH():
    ssh = paramiko.SSHClient()
    ssh.load_system_host_keys()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=server, port=22, username=user, password=passw)
    return ssh
#Used to get the SCP client for file transfers on the harveyv server
def getSCP():
    ssh = getSSH()
    scp = SCPClient(ssh.get_transport())
    return scp

directory = "~/cs432/CS432-p2/Interface"
server = "harveyv.binghamton.edu"
port = 22
#Generates new creds from user input or grabs existing creds
creds = login.main()
user = creds['user']
passw = creds['pass']
#Sends sqlplus creds to harveyv server
getSCP().put('c.JSON', directory+'/creds.JSON')

cmdPrefix = "cd " + directory + "; "
compileCmd = "javac -cp /usr/lib/oracle/18.3/client64/lib/ojdbc8.jar:json-simple-1.1.1.jar jdbcdemo1.java"
runCmdS = "java -cp /usr/lib/oracle/18.3/client64/lib/ojdbc8.jar:json-simple-1.1.1.jar op"

def startSql():
    cmd = cmdPrefix + "java -cp /usr/lib/oracle/18.3/client64/lib/ojdbc8.jar:json-simple-1.1.1.jar startSql.java"
#Used to form the run command for the selected JDBC operation on harveyv
def formRCmd(op):
    cmd = cmdPrefix + runCmdS + op + ".java"
    return cmd
#Used to compile java code - not actively being used
def runCompile(cmd):
	cmd = cmdPrefix + compileCmd
	ssh = getSSH()
	ssh.exec_command(cmd)
#Use with formRCmd to run any command, also gets the command's output from output.JSON file
def runCmd(cmd):
	ssh = getSSH()
	scp = getSCP()
	ssh.exec_command(cmd)
	time.sleep(2)
	scp.get(directory+'/output.JSON', 'output.JSON')
	return True
#Used to send input parameters to the harveyv server
def loadJSON(input):
	obj = json.dumps(input)
	with open("input.JSON", "w") as f:
		f.write(obj)
	scp = getSCP()
	scp.put('input.JSON', directory + '/input.JSON')
#Formats the output file received from harveyv to create the report
def parseJSON():
	f = open('output.JSON')
	data = json.load(f)
	h=getHeaders(data)
	v=getValues(data)
	return h, v
def getHeaders(data):
	return list(data["0"].values())
def getValues(data):
    v=[]
    first=True
    for row in data:
        if first:
            first=False
        else:
            v.append(list(data[row].values()))
    return v
