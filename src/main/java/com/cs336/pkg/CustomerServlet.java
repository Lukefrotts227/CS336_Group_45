package com.cs336.pkg;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.*;

public class CustomerServlet extends HttpServlet {
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
	        throws ServletException, IOException {

	        String action = request.getParameter("action");
	        HttpSession session = request.getSession(false);

	        if (session == null || session.getAttribute("username") == null) {
	            response.sendRedirect("login.jsp");
	            return;
	        }

	        String username = (String) session.getAttribute("username");
	        String customerEmail = null;
	        
	        try {
	            ApplicationDB db = new ApplicationDB();
	            try (Connection conn = db.getConnection()) {
	                String getEmailSQL = "SELECT email FROM customers WHERE username = ?";
	                try (PreparedStatement stmt = conn.prepareStatement(getEmailSQL)) {
	                    stmt.setString(1, username);
	                    try (ResultSet rs = stmt.executeQuery()) {
	                        if (rs.next()) {
	                            customerEmail = rs.getString("email");
	                        } else {
	                            // No matching user in customer table
	                            request.setAttribute("askQuestionMessage", "User not found.");
	                            request.getRequestDispatcher("/customer/customerDashboard.jsp").forward(request, response);
	                            return;
	                        }
	                    }
	                }
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	            request.setAttribute("askQuestionMessage", "Error retrieving user information.");
	            request.getRequestDispatcher("/customer/customerDashboard.jsp").forward(request, response);
	            return;
	        }

	        if ("askQuestion".equals(action)) {
	            String question = request.getParameter("question");

	            if (question == null || question.trim().isEmpty()) {
	                request.setAttribute("askQuestionMessage", "Question cannot be empty.");
	                request.getRequestDispatcher("/customer/customerDashboard.jsp").forward(request, response);
	                return;
	            }

	            try {
	                ApplicationDB db = new ApplicationDB();
	                try (Connection conn = db.getConnection()) {
	                    String sql = "INSERT INTO questions (customer, question) VALUES (?, ?)";
	                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
	                        stmt.setString(1, customerEmail);
	                        stmt.setString(2, question);
	                        stmt.executeUpdate();
	                    }
	                }

	                request.setAttribute("askQuestionMessage", "Your question has been submitted!");
	            } catch (Exception e) {
	                e.printStackTrace();
	                request.setAttribute("askQuestionMessage", "Error submitting question.");
	            }

	            // Forward back to dashboard with message
	            request.getRequestDispatcher("/customer/customerDashboard.jsp").forward(request, response);
	            return;
	        }
			else if ("reserve".equals(action)){
				String sh_Id = request.getParameter("scheduleId");
				String category = request.getParameter("category");
				if(sh_Id == null || category == null ){
					request.setAttribute("error", "Missing schedule ID or category.");
					request.getRequestDispatcher("customer/makeReservation.jsp").forward(request, response);
					return;
				}

				int scheduleId = Integer.parseInt(sh_Id);
				double rate = 0.0;

				switch (category) {
					case "child": rate = .75; break;
					case "disabled": rate = .50; break;
					case "elderly": rate = .65; break;
					default: rate = 1.0; category = "none"; 
				}
				try (Connection conn = new ApplicationDB().getConnection()) {
					String fareSql = "SELECT fare, departure_date_time FROM train_schedules WHERE schedule_id = ?";
		
				
					double baseFare; 
					Timestamp departTime; 

					try(PreparedStatement pf = conn.prepareStatement(fareSql)){

						pf.setInt(1, scheduleId); 
						try(ResultSet rs = pf.executeQuery()){
							if(!rs.next()) throw new SQLException("Could not find schedule"); 
							rate = rs.getDouble("fare"); 
							departTime = rs.getTimestamp("departure_date_time"); 
						}
					}
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}

			else{
	        // For unknown actions, redirect back to dashboard
	        response.sendRedirect("customer/customerdashboard.jsp");
	    }

	}
}
