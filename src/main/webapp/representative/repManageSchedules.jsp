<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"representative".equals(role)) {
%>
    <p>Access denied. This page is for representatives only.</p>
    <a href="login.jsp">Login</a>
<%
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT * FROM train_schedules");
%>

<h2>Manage Train Schedules</h2>

<table border="1">
<tr>
    <th>ID</th><th>Train #</th><th>Origin</th><th>Destination</th>
    <th>Departure</th><th>Arrival</th><th>Price</th><th>Actions</th>
</tr>

<%
    while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("train_number") %></td>
    <td><%= rs.getString("origin_station") %></td>
    <td><%= rs.getString("destination_station") %></td>
    <td><%= rs.getTimestamp("departure_time") %></td>
    <td><%= rs.getTimestamp("arrival_time") %></td>
    <td>$<%= rs.getBigDecimal("price") %></td>
    <td>
        <a href="editSchedule.jsp?id=<%= rs.getInt("id") %>">Edit</a> |
        <a href="deleteSchedule.jsp?id=<%= rs.getInt("id") %>">Delete</a>
    </td>
</tr>
<%
    }

    rs.close();
    stmt.close();
    conn.close();
%>
</table>

<a href="logout.jsp">Logout</a>
