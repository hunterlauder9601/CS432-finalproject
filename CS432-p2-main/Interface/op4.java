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

        //Connection to Oracle server. Receives username and
        //password from creds.json file. creds file sent by web interface
	OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
	ds.setURL("jdbc:oracle:thin:@castor.cc.binghamton.edu:1521:acad111");

	JSONParser parser = new JSONParser();
	String content = new Scanner(new File("./creds.JSON")).nextLine();
	JSONObject creds = (JSONObject) parser.parse(content);
	String user = creds.get("user").toString();
	String passw = creds.get("pass").toString();
	Connection conn = ds.getConnection(user, passw);

	String varCont = new Scanner(new File("./input.JSON")).nextLine();
	JSONObject vars = (JSONObject) parser.parse(varCont);
	String dept_code = vars.get("dept_code").toString();
	int courseN = Integer.parseInt(vars.get("course#").toString());

        JSONObject obj = new JSONObject();

	// Query to receive the dbms_output.put_line(...) from sql statements
	Statement s = conn.createStatement ();
	s.executeUpdate("begin dbms_output.enable(); end;");
	CallableStatement stmt = conn.prepareCall ("call proj2.pre_reqs2(?,?)"); //Query to call the procedure
	stmt.setString(1, dept_code);
	stmt.setInt(2, courseN);
	// Save result
	ResultSet rset;
	rset = stmt.executeQuery();
	// Query to receive the dbms_output.put_line(...) from sql statements
	CallableStatement call = conn.prepareCall(
            "declare "
          + "  num integer := 1000;"
          + "begin "
          + "  dbms_output.get_lines(?, num);"
          + "end;"
        );
	call.registerOutParameter(1, Types.ARRAY, "DBMSOUTPUT_LINESARRAY");
        call.execute();
	Array array = call.getArray(1); //Array holding the ouput from the sql
	String h;
	String[] row;
	int i = 0;
        //Form JSON object from received output
	JSONObject ob = new JSONObject();
	ob.put(0, "Course");
	obj.put(0, ob);

	for (i=1 ; i < Arrays.asList((Object[]) array.getArray()).size() ; i++) {
	   h = (String) Arrays.asList((Object[]) array.getArray()).get(i-1);
	   row = h.split("\\s+");
	   JSONObject o = new JSONObject();
	   for(int j = 0 ; j < row.length ; j++){
		o.put(j, row[j]);
	   }
	   obj.put(i, o);
	}

	//close the result set, statement, and the connection
	//rset.close();
	stmt.close();
	conn.close();
	//Writes output to the output.JSON file to be sent to web interface
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
