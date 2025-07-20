package com.cs336.pkg;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.Connection;
import java.sql.PreparedStatement;

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

	        // For unknown actions, redirect back to dashboard
	        response.sendRedirect("/customer/customerDashboard.jsp");
	    }

}
