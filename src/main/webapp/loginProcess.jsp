<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    boolean valid = false;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/cs336_group45?useSSL=false",
            "root", "bigmike123"
        );

        PreparedStatement stmt = conn.prepareStatement(
        	    "SELECT role FROM users WHERE username=? AND password=?"
        	);
        	stmt.setString(1, username);
        	stmt.setString(2, password);
        	ResultSet rs = stmt.executeQuery();

        	if (rs.next()) {
        	    valid = true;
        	    String role = rs.getString("role");
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
%>
        <p>Login successful. Welcome, <%= username %>! You are logged in as <%= session.getAttribute("role") %>.</p>

<%
    String role = (String) session.getAttribute("role");
    if ("customer".equals(role)) {
%>
        <a href="searchSchedules.jsp">Search Train Schedules</a><br/>
        <a href="myReservations.jsp">View My Reservations</a><br/>
        <a href="askQuestion.jsp">Ask a Question</a><br/>
        
        
        
<%
    } else if ("representative".equals(role)) {
%>
          <a href="repManageSchedules.jsp">Manage Train Schedules</a><br/>
          <a href="repAnswerQuestions.jsp">Answer Customer Questions</a><br/>
          <a href="repListCustomers.jsp">List Customers for Train & Date</a><br/>
          <a href="repListSchedulesByStation.jsp">List Schedules for Station</a><br/>
          
          
          
<%
    } else if ("manager".equals(role)) {
%>
        <p>Manager dashboard coming soon!</p>
<%
    }
%>

<a href="logout.jsp">Logout</a>


<%
    } else {
%>
        <p>Login failed. Invalid username or password.</p>
        <a href="login.jsp">Try Again</a>
<%
    }
%>