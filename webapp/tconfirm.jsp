<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="org.commschool.scheduler.*" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DateFormat" %>

<%
String teacherName = (String)session.getAttribute( "teacherName" );
int teacherID = ((Integer)session.getAttribute( "teacherID" )).intValue();
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

int numberOfTimeSlots = 0;

if ( teacherName == null ) {
   %><jsp:forward page="tlogin.jsp" /><%
}

try {
    state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
} catch ( SQLException e ) {
    %>Internal SQL Error.<%
}
%>

<head>
  <meta http-equiv="content-type"
 content="text/html; charset=ISO-8859-1">
  <title>Request Conferences for <%= teacherName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<br><big><big style="font-weight: bold;">Confirmation</big></big><br>
<p>Please confirm that the following information is correct. A confirmation email has also been sent to the email address you entered. 
<p>You have indicated that you will be available for the following time slots:
<ul><%

ResultSet results = state.executeQuery( "SELECT start, end FROM available WHERE type = 1 AND ID = " + teacherID );

while( results.next() ) { 
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format( results.getTimestamp( 1 ) ) + " " + tdf.format( results.getTimestamp( 1 ) ) %> - <%= tdf.format( results.getTimestamp( 2 ) ) %></li>
<% } %></ul>

<p />

Your have selected that you would like to meet with the following students in the priority listed: (9 is highest priority)
<p><%

results = state.executeQuery( "SELECT students.name, rank, max_conferences FROM preferences LEFT JOIN students ON preferences.withID = students.studentID WHERE isTeacher = 1 AND ID = " + teacherID + " ORDER BY preferences.rank" );
%>
<table border="1">
<tr><td>Priority</td><td>Student</td></tr>
<%
while( results.next() ) { %>
    <tr><td><%= results.getInt( 2 ) %><%= results.getInt( 3 ) > 1 ? " (2 conferences)" : "" %></td><td><%= results.getString( 1 ) %></td></tr>
<% } %>
</table>
<br>
<%
results = state.executeQuery( "SELECT email FROM teachers WHERE teacherID = " + teacherID );
results.first();
String teacherEmail = results.getString( 1 );
%>
You have indicated that you wish your final schedule to be emailed to "<%= teacherEmail %>".

<p>Please click <a href="trequest.jsp">here</a> if you would like to change this information by redoing the signup procedure. Otherwise, please wait for your final schedule to be emailed to you.

<%

results = state.executeQuery( "SELECT * FROM templates WHERE name = \"confirm-teacher\"" );
results.first();
String temp = results.getString( 2 );

results = state.executeQuery( "SELECT SMTPserver, mailFrom FROM config" );
results.first();
String server = results.getString( 1 );
String mailFrom = results.getString( 2 );

temp = temp.replaceAll( "%t", teacherName );
temp = temp.replaceAll( "%e", teacherEmail );
temp = temp.replaceAll( "%a", mailFrom );

String timeBlock = temp.substring( temp.indexOf( "%x" ) + 2, temp.lastIndexOf( "%x" ) -1 );
temp = temp.replaceAll( "\\Q" + timeBlock, "" );
temp = temp.replaceFirst( "\n%x", "" );

String timeArea = "";
results = state.executeQuery( "SELECT start, end FROM available WHERE type = 1 AND ID = " + teacherID );
while( results.next() ) {
    timeArea += timeBlock;
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    timeArea = timeArea.replaceAll( "%s", tdf.format( results.getTimestamp( 1 ) ) + " " + ddf.format( results.getTimestamp( 1 ) ) );
    timeArea = timeArea.replaceAll( "%f", tdf.format( results.getTimestamp( 2 ) ) );
}

temp = temp.replaceAll( "%x", timeArea );

Hashtable ht = new Hashtable();
results = state.executeQuery( "SELECT students.name, classes.name FROM classMembers LEFT JOIN classes ON classes.classID = classMembers.classID LEFT JOIN students ON classMembers.studentID = students.studentID WHERE classes.teacherID = " + teacherID );

while ( results.next() ) {
    String s = (String)ht.get( results.getString( 1 ) );
    if ( s == null )
	ht.put( results.getString( 1 ), results.getString( 2 ) );
    else
	ht.put( results.getString( 1 ), s + ", " + results.getString( 2 ) );
}

String prefBlock = temp.substring( temp.indexOf( "%y" ) + 2, temp.lastIndexOf( "%y" ) -1 );
temp = temp.replaceAll( "\\Q" + prefBlock, "" );
temp = temp.replaceFirst( "\n%y", "" );

String prefArea = "";
results = state.executeQuery( "SELECT students.name, preferences.rank, preferences.max_conferences FROM preferences LEFT JOIN students ON students.studentID = preferences.withID WHERE isTeacher = 1 AND ID = " + teacherID );
while( results.next() ) {
    prefArea += prefBlock;
    prefArea = prefArea.replaceAll( "%n", results.getString( 1 ) );
    prefArea = prefArea.replaceAll( "%c", (String)ht.get( results.getString( 1 ) ) );
    prefArea = prefArea.replaceAll( "%r", results.getInt( 2 ) + "" );
    if ( results.getInt( 3 ) > 1 )
	prefArea = prefArea.replaceAll( "%m", "(two conferences)" );
}

temp = temp.replaceAll( "%y", prefArea );

boolean result = Sendmail.send( server, mailFrom, teacherEmail, temp );
if ( !result ) {
    %><br>Error sending mail to <%= teacherEmail %>! See server logs for details.<%
}

%>

</body>
</html>