<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"representative".equals(role)) {
%>
    <p>Access denied. <a href="login.jsp">Login</a></p>
<%
        return;
    }

    String station = request.getParameter("station");
%>

<h2>List Schedules for a Station</h2>

<form method="get">
    Station Name: <input type="text" name="station" value="<%= station != null ? station : "" %>"><br/>
    <input type="submit" value="Search">
</form>

<%
    if (station != null && !station.trim().isEmpty()) {
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        PreparedStatement stmt = conn.prepareStatement(
            "SELECT * FROM train_schedules WHERE origin_station=? OR destination_station=?"
        );
        stmt.setString(1, station);
        stmt.setString(2, station);

        ResultSet rs = stmt.executeQuery();
%>

<h3>Schedules for Station: <%= station %></h3>

<table border="1">
<tr><th>ID</th><th>Train</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Arrival</th><th>Price</th></tr>

<%
        boolean hasResults = false;
        while(rs.next()) {
            hasResults = true;
%>
<tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("train_number") %></td>
    <td><%= rs.getString("origin_station") %></td>
    <td><%= rs.getString("destination_station") %></td>
    <td><%= rs.getTimestamp("departure_time") %></td>
    <td><%= rs.getTimestamp("arrival_time") %></td>
    <td>$<%= rs.getBigDecimal("price") %></td>
</tr>
<%
        }
        if (!hasResults) {
%>
<tr><td colspan="7">No schedules found for this station.</td></tr>
<%
        }

        rs.close();
        stmt.close();
        conn.close();
    }
%>
</table>

<a href="logout.jsp">Logout</a>
