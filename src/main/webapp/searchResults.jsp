<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");
    String date = request.getParameter("date");

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    StringBuilder sql = new StringBuilder("SELECT * FROM train_schedules WHERE 1=1");
    if (origin != null && !origin.trim().isEmpty()) {
        sql.append(" AND origin_station=?");
    }
    if (destination != null && !destination.trim().isEmpty()) {
        sql.append(" AND destination_station=?");
    }
    if (date != null && !date.trim().isEmpty()) {
        sql.append(" AND DATE(departure_time)=?");
    }

    PreparedStatement stmt = conn.prepareStatement(sql.toString());

    int paramIndex = 1;
    if (origin != null && !origin.trim().isEmpty()) {
        stmt.setString(paramIndex++, origin);
    }
    if (destination != null && !destination.trim().isEmpty()) {
        stmt.setString(paramIndex++, destination);
    }
    if (date != null && !date.trim().isEmpty()) {
        stmt.setString(paramIndex++, date);
    }

    ResultSet rs = stmt.executeQuery();
%>

<h2>Search Results</h2>

<table border="1">
<tr><th>Train</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Arrival</th><th>Price</th><th>Action</th>
</tr>

<%
    boolean hasResults = false;
    while(rs.next()) {
        hasResults = true;
%>
<tr>
    <td><%= rs.getString("train_number") %></td>
    <td><%= rs.getString("origin_station") %></td>
    <td><%= rs.getString("destination_station") %></td>
    <td><%= rs.getTimestamp("departure_time") %></td>
    <td><%= rs.getTimestamp("arrival_time") %></td>
    <td>$<%= rs.getBigDecimal("price") %></td>
    <td><a href="makeReservation.jsp?scheduleId=<%= rs.getInt("id") %>">Reserve</a></td>
    
</tr>
<%
    }
    if (!hasResults) {
%>
<tr><td colspan="6">No results found.</td></tr>
<%
    }
    rs.close();
    stmt.close();
    conn.close();
%>
</table>

<a href="searchSchedules.jsp">Search Again</a><br/>
<a href="logout.jsp">Logout</a>
