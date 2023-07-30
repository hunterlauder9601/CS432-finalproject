import java.sql.*;
import oracle.jdbc.*;
import java.math.*;
import java.io.*;
import java.io.FileReader;
import java.util.*;
import java.awt.*;
import oracle.jdbc.pool.OracleDataSource;
import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import java.nio.file.Path;
import java.nio.file.Files;

//compile
//   javac -cp /usr/lib/oracle/18.3/client64/lib/ojdbc8.jar:json-simple-1.1.1.jar jdbcdemo1.java
//run
//   java -cp /usr/lib/oracle/18.3/client64/lib/ojdbc8.jar:json-simple-1.1.1.jar jdbcdemo1.java
 
public class jdbcdemo1 {

     public static void main (String args []) throws SQLException {
       	String filePath = new File("").getAbsolutePath();
	try
       {
	
        //Connection to Oracle server. Need to replace username and
        //password by your username and your password. For security
        //consideration, it's better to read them in from keyboard.
	OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
	ds.setURL("jdbc:oracle:thin:@castor.cc.binghamton.edu:1521:acad111");
	
	JSONParser parser = new JSONParser();
	String content = new Scanner(new File("./creds.JSON")).nextLine();
	JSONObject creds = (JSONObject) parser.parse(content);
	String user = creds.get("user").toString();
	String passw = creds.get("pass").toString();
	Connection conn = ds.getConnection(user, passw);

        JSONObject obj = new JSONObject();
	
	// Query
	CallableStatement stmt = conn.prepareCall ("start q2;");
	// Save result
	ResultSet rset;
	rset = stmt.executeQuery();

	//close the result set, statement, and the connection
	rset.close();
	stmt.close();
	conn.close();
 	StringWriter out = new StringWriter();
	FileWriter file = new FileWriter("./output.JSON");
	obj.writeJSONString(out);
	String jsonText = out.toString();
	file.write(jsonText);
	file.close();
	System.out.print(jsonText);
     }
	
	catch (SQLException ex) { ex.printStackTrace(); System.out.println ("\n*** SQLException caught ***\n");}
	catch (FileNotFoundException ex){ System.out.println("\n*** File Except caught***\n");}
	catch (Exception e) {e.printStackTrace(); System.out.println ("\n*** other Exception caught ***\n");}
  }
}


