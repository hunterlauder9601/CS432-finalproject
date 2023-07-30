#run using
#	python3 -m flask run

from flask import Flask, render_template, request
import harvey_connect

app = Flask(__name__)

#This file is a flask based web server and serves as the web interface

#Used to mark & identify the options of reports to view from question 2
op2Helper = {
    'Students': 'a',
    'Logs': 'b',
    'G_Enrollment': 'c',
    'Courses': 'd',
    'Prerequisites': 'e',
    'Credit': 'f',
    'Classes': 'g',
    'Score': 'h'
}
#Used to store details needed for each operation
opDetails = {
    "1": {"fields": [], "title": "Reset Tables", "action": "Reset"},
    "2": {"fields": list(op2Helper.keys()), "title": "Display Tables", "action": "Search"},
    "3": {"fields": ['classid'], "title": "Class Participants", "action": "Search"},
    "4": {"fields": ['dept_code','course#'], "title": "Find Prerequisites", "action": "Search"},
    "5": {"fields": ['B#', 'classid'], "title": "Enroll Graduate Student", "action": "Enroll"},
    "6": {"fields": ['B#', 'classid'], "title": "Drop Graduate Students", "action": "Drop"},
    "7": {"fields": ['B#'], "title": "Remove Student", "action": "Remove"}
}

#Displays the home screen
@app.route("/")
def home():
    return(render_template('main.html',opDetails=opDetails))

#Displays the reporting screen
#Receives arguments from the user and changes the view accordingly
@app.route("/report")
def report():
    functionTitle = "REPLACE"
    curOp=request.args.get('op')
    functionDescription = ""

    if request.args.get('op') in opDetails.keys():
        fl=opDetails[request.args.get('op')]["fields"]
        functionTitle=opDetails[request.args.get('op')]["title"]
        opAction=opDetails[request.args.get('op')]["action"]
    else:
        fl=[]
        functionTitle="Invalid Operation"
        opAction=""
    if request.args.get('search') == "1" and opAction!="":
        sendOp(curOp, request)
        useOp = request.args.get('op')
        if useOp=="2":
            useOp+=request.args.get('secondary')
        harvey_connect.runCmd(harvey_connect.formRCmd(useOp)) #calls and runs the JDBC operation
        h, t = harvey_connect.parseJSON()
        w=(100/len(h))
    else:
        h=["Waiting for valid query..."]
        t=[]
        w=100
    return(render_template('report.html',**locals(),table=t,headers=h,fieldList=fl,opDetails=opDetails,op2Helper=op2Helper))

def sendOp(op, r):
    d={}
    for field in opDetails[op]["fields"]:
        d[field] = request.args.get(field)
    harvey_connect.loadJSON(d)
