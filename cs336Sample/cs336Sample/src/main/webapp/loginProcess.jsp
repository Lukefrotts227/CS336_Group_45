<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String role = null;

    boolean valid = false;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/trainbookingdb?useSSL=false",
            "jspuser", "jsp123"
        );

        PreparedStatement stmt = conn.prepareStatement(
            "SELECT * FROM User WHERE username=? AND password=?"
        );
        stmt.setString(1, username);
        stmt.setString(2, password);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            valid = true;
            role = rs.getString("role");
            session.setAttribute("username", username);
            session.setAttribute("role", role);
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }

    if (valid) {
    	if ("admin".equalsIgnoreCase(role)) {
            response.sendRedirect("adminDashboard.jsp");
        } else if ("employee".equalsIgnoreCase(role)) {
            response.sendRedirect("employeeDashboard.jsp");
        } else if ("customer".equalsIgnoreCase(role)) {
            response.sendRedirect("customerDashboard.jsp");
        } else {
            // Unknown role: fallback page or logout
            response.sendRedirect("login.jsp?error=UnknownUserRole");
        }
    } else {
%>
        <p>Login failed. Invalid username or password.</p>
        <a href="login.jsp">Try Again</a>
<%
    }
%>