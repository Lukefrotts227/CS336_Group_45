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

    String idParam = request.getParameter("id");
    if (idParam == null) {
%>
    <p>No schedule ID provided.</p>
    <a href="repManageSchedules.jsp">Back</a>
<%
        return;
    }

    int scheduleId = Integer.parseInt(idParam);

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Handle form submission
        String trainNumber = request.getParameter("train_number");
        String origin = request.getParameter("origin_station");
        String destination = request.getParameter("destination_station");
        String departure = request.getParameter("departure_time");
        String arrival = request.getParameter("arrival_time");
        String price = request.getParameter("price");

        PreparedStatement updateStmt = conn.prepareStatement(
            "UPDATE train_schedules SET train_number=?, origin_station=?, destination_station=?, departure_time=?, arrival_time=?, price=? WHERE id=?"
        );
        updateStmt.setString(1, trainNumber);
        updateStmt.setString(2, origin);
        updateStmt.setString(3, destination);
        updateStmt.setString(4, departure);
        updateStmt.setString(5, arrival);
        updateStmt.setBigDecimal(6, new java.math.BigDecimal(price));
        updateStmt.setInt(7, scheduleId);

        int result = updateStmt.executeUpdate();

        updateStmt.close();
        conn.close();

        if (result > 0) {
%>
    <p>Schedule updated successfully.</p>
<%
        } else {
%>
    <p>Failed to update schedule.</p>
<%
        }
%>
    <a href="repManageSchedules.jsp">Back to Manage Schedules</a>
<%
        return;
    }

    // GET request - show current values
    PreparedStatement stmt = conn.prepareStatement(
        "SELECT * FROM train_schedules WHERE id=?"
    );
    stmt.setInt(1, scheduleId);

    ResultSet rs = stmt.executeQuery();
    if (!rs.next()) {
%>
    <p>Schedule not found.</p>
    <a href="repManageSchedules.jsp">Back</a>
<%
        rs.close();
        stmt.close();
        conn.close();
        return;
    }
%>

<h2>Edit Schedule ID <%= scheduleId %></h2>

<form method="post" action="editSchedule.jsp?id=<%= scheduleId %>">
    Train Number: <input type="text" name="train_number" value="<%= rs.getString("train_number") %>"><br/>
    Origin: <input type="text" name="origin_station" value="<%= rs.getString("origin_station") %>"><br/>
    Destination: <input type="text" name="destination_station" value="<%= rs.getString("destination_station") %>"><br/>
    Departure: <input type="text" name="departure_time" value="<%= rs.getTimestamp("departure_time") %>"><br/>
    Arrival: <input type="text" name="arrival_time" value="<%= rs.getTimestamp("arrival_time") %>"><br/>
    Price: <input type="text" name="price" value="<%= rs.getBigDecimal("price") %>"><br/>
    <input type="submit" value="Update">
</form>

<a href="repManageSchedules.jsp">Back to Manage Schedules</a>

<%
    rs.close();
    stmt.close();
    conn.close();
%>
