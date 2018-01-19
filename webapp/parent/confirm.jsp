<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= studentName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<h2>Confirmation</h2>
<p>Please confirm that the following information is correct.</p>
<p>You have indicated that you will be available for the following time
slots:</p>
<ul><%
ResultSet results = state.executeQuery("SELECT start, end FROM available WHERE type = 0 AND ID = " + studentID);
while(results.next()) { 
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format(results.getTimestamp(1)) + " " + tdf.format(results.getTimestamp(1)) %> - <%= tdf.format(results.getTimestamp(2)) %></li>
<% } %></ul>

<p>You have selected that you would like to meet with the following teachers in
the priority listed: (9 is highest priority)</p>
<%
results = state.executeQuery("SELECT teachers.name, rank, max_conferences FROM preferences LEFT JOIN teachers ON preferences.withID = teachers.teacherID WHERE isTeacher = 0 AND ID = " + studentID + " ORDER BY preferences.rank");
%>
<table>
<tr><td>Priority</td><td>Teacher</td></tr>
<%
while(results.next()) { %>
    <tr>
		<td><%= results.getInt(2) %><%= (results.getInt(3) > 1) ? " (2 conferences)" : "" %></td>
		<td><%= results.getString(1) %></td>
	</tr>
<% } %>
</table>
<!--<p>You have indicated that you wish your final schedule to be emailed to 
"<%= studentEmail %>".</p> -->
<p>Please click <a href="/parent/request.jsp">here</a> if you would like to change this
information by redoing the signup procedure. Otherwise, you're done! Please check back the day before the conferences to see your schedule.</p>

<!--<%
results = state.executeQuery("SELECT * FROM templates WHERE name = \"confirm-parent\"");
results.first();
String temp = results.getString(2);

results = state.executeQuery( "SELECT SMTPserver, mailFrom FROM config" );
results.first();
String server = results.getString(1);
String mailFrom = results.getString(2);

temp = temp.replaceAll("%n", studentName);
temp = temp.replaceAll("%e", studentEmail);
temp = temp.replaceAll("%a", mailFrom);

String timeBlock = temp.substring(temp.indexOf("%x") + 2, temp.lastIndexOf("%x") - 1);
temp = temp.replaceAll("\\Q" + timeBlock, "");
temp = temp.replaceFirst("\n%x", "");

String timeArea = "";
results = state.executeQuery("SELECT start, end FROM available WHERE type = 0 AND ID = " + studentID);
while (results.next()) {
    timeArea += timeBlock;
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    timeArea = timeArea.replaceAll("%s", tdf.format(results.getTimestamp(1)) + " " + ddf.format(results.getTimestamp(1)));
    timeArea = timeArea.replaceAll("%f", tdf.format(results.getTimestamp(2)));
}

temp = temp.replaceAll("%x", timeArea);

Hashtable ht = new Hashtable();
results = state.executeQuery("SELECT teachers.name, classes.name FROM classMembers LEFT JOIN classes ON classes.classID = classMembers.classID LEFT JOIN teachers ON classes.teacherID = teachers.teacherID WHERE studentID = " + studentID);

while (results.next()) {
    String s = (String)ht.get(results.getString(1));
    if (s == null)
		ht.put(results.getString(1), results.getString(2));
    else
		ht.put(results.getString(1), s + ", " + results.getString(2));
}

String prefBlock = temp.substring(temp.indexOf("%y") + 2, temp.lastIndexOf("%y") - 1);
temp = temp.replaceAll("\\Q" + prefBlock, "");
temp = temp.replaceFirst("\n%y", "");

String prefArea = "";
results = state.executeQuery("SELECT teachers.name, preferences.rank, preferences.max_conferences FROM preferences LEFT JOIN teachers ON teachers.teacherID = preferences.withID WHERE isTeacher = 0 AND ID = " + studentID);
while (results.next()) {
    prefArea += prefBlock;
    prefArea = prefArea.replaceAll("%t", results.getString(1));
    prefArea = prefArea.replaceAll("%c", (String)ht.get(results.getString(1)));
    prefArea = prefArea.replaceAll("%r", results.getInt(2) + "");
    if (results.getInt(3) > 1)
		prefArea = prefArea.replaceAll("%m", "(two conferences)");
}

temp = temp.replaceAll("%y", prefArea);

boolean result = Sendmail.send(server, mailFrom, studentEmail, temp);
%> -->
</body>
</html>