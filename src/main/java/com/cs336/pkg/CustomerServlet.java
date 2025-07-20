package com.cs336.pkg;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
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

	        if ("askQuestion".equals(action)) {
	            String question = request.getParameter("question");

	            if (question == null || question.trim().isEmpty()) {
	                request.setAttribute("askQuestionMessage", "Question cannot be empty.");
	                request.getRequestDispatcher("customer/customerdashboard.jsp").forward(request, response);
	                return;
	            }

	            try {
	                ApplicationDB db = new ApplicationDB();
	                try (Connection conn = db.getConnection()) {
	                    String sql = "INSERT INTO questions (customer, question) VALUES (?, ?)";
	                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
	                        stmt.setString(1, username);
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
	            request.getRequestDispatcher("customer/customerdashboard.jsp").forward(request, response);
	            return;
	        }

	        // For unknown actions, redirect back to dashboard
	        response.sendRedirect("customer/customerdashboard.jsp");
	    }

}
