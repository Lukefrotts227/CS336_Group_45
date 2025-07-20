<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
    String username = (String) session.getAttribute("username");

    if (username == null) {
%>
        <p>Please <a href="login.jsp">log in</a> first.</p>
<%
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    PreparedStatement stmt = conn.prepareStatement(
        "SELECT r.id AS reservation_id, ts.train_number, ts.origin_station, ts.destination_station, ts.departure_time, ts.arrival_time, ts.price " +
        "FROM reservations r JOIN train_schedules ts ON r.schedule_id = ts.id " +
        "WHERE r.username=?"
    );
    stmt.setString(1, username);

    ResultSet rs = stmt.executeQuery();
%>

<h2>My Reservations</h2>

<table border="1">
<tr><th>Reservation ID</th><th>Train</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Arrival</th><th>Price</th><th>Action</th></tr>

<%
    boolean hasResults = false;
    while(rs.next()) {
        hasResults = true;
%>
<tr>
    <td><%= rs.getInt("reservation_id") %></td>
    <td><%= rs.getString("train_number") %></td>
    <td><%= rs.getString("origin_station") %></td>
    <td><%= rs.getString("destination_station") %></td>
    <td><%= rs.getTimestamp("departure_time") %></td>
    <td><%= rs.getTimestamp("arrival_time") %></td>
    <td>$<%= rs.getBigDecimal("price") %></td>
    <td><a href="cancelReservation.jsp?reservationId=<%= rs.getInt("reservation_id") %>">Cancel</a></td>
</tr>
<%
    }
    if (!hasResults) {
%>
<tr><td colspan="8">No reservations found.</td></tr>
<%
    }
    rs.close();
    stmt.close();
    conn.close();
%>
</table>