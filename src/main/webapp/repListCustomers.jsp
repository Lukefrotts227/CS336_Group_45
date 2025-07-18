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

    String trainNumber = request.getParameter("trainNumber");
    String date = request.getParameter("date");
%>

<h2>List Customers for Train and/or Date</h2>

<form method="get">
    Train Number: <input type="text" name="trainNumber" value="<%= trainNumber != null ? trainNumber : "" %>"><br/>
    Date (YYYY-MM-DD): <input type="text" name="date" value="<%= date != null ? date : "" %>"><br/>
    <input type="submit" value="Search">
</form>

<%
    if ((trainNumber != null && !trainNumber.trim().isEmpty()) ||
        (date != null && !date.trim().isEmpty())) {

        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        StringBuilder sql = new StringBuilder(
        	    "SELECT DISTINCT r.username FROM reservations r " +
        	    "JOIN train_schedules ts ON r.schedule_id = ts.id " +
        	    "JOIN users u ON r.username = u.username " +
        	    "WHERE u.role='customer'"
        	);


        if (trainNumber != null && !trainNumber.trim().isEmpty()) {
            sql.append(" AND ts.train_number=?");
        }
        if (date != null && !date.trim().isEmpty()) {
            sql.append(" AND DATE(ts.departure_time)=?");
        }

        PreparedStatement stmt = conn.prepareStatement(sql.toString());

        int paramIndex = 1;
        if (trainNumber != null && !trainNumber.trim().isEmpty()) {
            stmt.setString(paramIndex++, trainNumber);
        }
        if (date != null && !date.trim().isEmpty()) {
            stmt.setString(paramIndex++, date);
        }

        ResultSet rs = stmt.executeQuery();
%>

<h3>Results:</h3>

<ul>
<%
        boolean found = false;
        while (rs.next()) {
            found = true;
%>
    <li><%= rs.getString("username") %></li>
<%
        }
        if (!found) {
%>
    <li>No customers found.</li>
<%
        }

        rs.close();
        stmt.close();
        conn.close();
    }
%>
</ul>

<a href="logout.jsp">Logout</a>
