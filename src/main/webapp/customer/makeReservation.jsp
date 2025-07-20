<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page session="true" contentType="text/html charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Make a Reservation</title>
</head>
<body>

<%
    String username = (String) session.getAttribute("username");
    String scheduleId = request.getParameter("scheduleId");

    if (username == null || scheduleId == null) {
%>
        <p>Error: Missing session or schedule ID. Please log in and try again.</p>
        <a href="login.jsp">Login</a>
<%
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    PreparedStatement stmt = conn.prepareStatement(
        "INSERT INTO reservations (username, schedule_id) VALUES (?, ?)"
    );
    stmt.setString(1, username);
    stmt.setInt(2, Integer.parseInt(scheduleId));

    int result = stmt.executeUpdate();

    stmt.close();
    conn.close();

    if (result > 0) {
%>
        <p>Reservation successful for train schedule ID <%= scheduleId %>!</p>
<%
    } else {
%>
        <p>Reservation failed. Please try again.</p>
<%
    }
%>

</body>
</html>