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

    PreparedStatement stmt = conn.prepareStatement(
        "DELETE FROM train_schedules WHERE id=?"
    );
    stmt.setInt(1, scheduleId);

    int result = stmt.executeUpdate();

    stmt.close();
    conn.close();

    if (result > 0) {
%>
    <p>Schedule <%= scheduleId %> deleted successfully.</p>
<%
    } else {
%>
    <p>Failed to delete schedule <%= scheduleId %>. It may not exist.</p>
<%
    }
%>

<a href="repManageSchedules.jsp">Back to Manage Schedules</a>
