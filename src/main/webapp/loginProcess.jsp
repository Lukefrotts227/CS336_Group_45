<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%

	ApplicationDB db = new ApplicationDB();
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    boolean valid = false;

    try {
        conn = db.getConnection();

        stmt = conn.prepareStatement(
        	    "SELECT username FROM users WHERE username=? AND password=?"
        	);
        	stmt.setString(1, username);
        	stmt.setString(2, password);
        	rs = stmt.executeQuery();

        	if (rs.next()) {
        	    valid = true;
        	    session.setAttribute("username", username);
        	    
        	    PreparedStatement roleStmt = conn.prepareStatement(
        	    		"SELECT user_type FROM user_roles where username=?"
        	    );
        	    roleStmt.setString(1, username);
        	    ResultSet roleRs = roleStmt.executeQuery();
        	    
        	    if (roleRs.next()) {
        	    	String role = roleRs.getString("user_type");
        	    	session.setAttribute("role", role);
        	    }
        	    
        	    roleRs.close();
        	    roleStmt.close();
        	}
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
    	if (rs != null) { rs.close(); }
    	if (stmt != null) {stmt.close(); }
    	if (conn != null) {
    		db.closeConnection(conn);
    	}
    }

    if (valid) {
    	String role = (String) session.getAttribute("role");
    	if ("customer".equals(role)) {
    		response.sendRedirect("customer/customerDashboard.jsp");
    	} else if ("representative".equals(role)) {
    		response.sendRedirect("representative/representativeDashboard.jsp");
    	} else if ("manager".equals(role)) {
    		response.sendRedirect("admin/adminDashboard.jsp");
    	} else {
%>
        <p>Unknown role: <%= role %>. Please contact support.</p>
        <a href="login.jsp">Login</a>
<%
    	}
    } else {
%>
		<p>Login failed. Invalid username or password.</p>
        <a href="login.jsp">Try Again</a>
<% 
    }
%>