<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    if (username == null || role == null || !role.equalsIgnoreCase("admin")) {
        response.sendRedirect("login.jsp?error=AccessDenied");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
</head>
<body>

<ul>
<li><a href=manageUsers.jsp>Manage Users</a></li>
<li><a href=manageTrains.jsp>Manage Trains</a></li>
<li><a href=manageSchedules.jsp>Manage Schedules</a></li>
<li><a href=reviewFinances.jsp>Review Finances</a></li>
<li><a href=logout.jsp>Logout</a></li>
</ul>

</body>
</html>