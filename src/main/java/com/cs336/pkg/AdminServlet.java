package com.cs336.pkg;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // 📊 Monthly Sales Report
        if ("monthlyReport".equals(action)) {
            List<String[]> report = new ArrayList<>();
            try {
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();
                String query = "SELECT YEAR(reservation_date) AS year, MONTH(reservation_date) AS month, SUM(price) AS total " +
                               "FROM Reservations GROUP BY year, month ORDER BY year, month";
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String[] row = {
                        rs.getString("year"),
                        rs.getString("month"),
                        rs.getString("total")
                    };
                    report.add(row);
                }
                rs.close();
                ps.close();
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            request.setAttribute("monthlyReport", report);
            request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
            return;
        }

        // 💰 Revenue by Line or Customer
        else if ("revenueLookup".equals(action)) {
            String transitLineId = request.getParameter("transitLineId");
            String customerId = request.getParameter("customerId");
            String total = "0.00";

            try {
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();
                String query = "";
                PreparedStatement ps;

                if (transitLineId != null && !transitLineId.isEmpty()) {
                    query = "SELECT SUM(price) AS total FROM Reservations WHERE transit_line_id = ?";
                    ps = con.prepareStatement(query);
                    ps.setString(1, transitLineId);
                } else {
                    query = "SELECT SUM(price) AS total FROM Reservations WHERE customer_id = ?";
                    ps = con.prepareStatement(query);
                    ps.setString(1, customerId);
                }

                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    total = rs.getString("total") != null ? rs.getString("total") : "0.00";
                }

                rs.close();
                ps.close();
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("revenueResult", total);
            request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
            return;
        }

        // 🏆 Top 5 Customers
        else if ("topCustomers".equals(action)) {
            List<String[]> topCustomers = new ArrayList<>();
            try {
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();
                String query = "SELECT c.id, c.name, SUM(r.price) AS total_spent " +
                               "FROM Reservations r JOIN Customers c ON r.customer_id = c.id " +
                               "GROUP BY c.id, c.name ORDER BY total_spent DESC LIMIT 5";
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String[] row = {
                        rs.getString("id"),
                        rs.getString("name"),
                        rs.getString("total_spent")
                    };
                    topCustomers.add(row);
                }
                rs.close();
                ps.close();
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("topCustomers", topCustomers);
            request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
            return;
        }

        // 🚆 Top 5 Active Transit Lines (Per Month)
        else if ("topTransitLines".equals(action)) {
            List<String[]> topTransitLines = new ArrayList<>();
            try {
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();
                String query = "SELECT YEAR(reservation_date) AS year, MONTH(reservation_date) AS month, " +
                               "transit_line_id, COUNT(*) AS reservation_count " +
                               "FROM Reservations GROUP BY year, month, transit_line_id " +
                               "ORDER BY reservation_count DESC LIMIT 5";
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String[] row = {
                        rs.getString("year"),
                        rs.getString("month"),
                        rs.getString("transit_line_id"),
                        rs.getString("reservation_count")
                    };
                    topTransitLines.add(row);
                }
                rs.close();
                ps.close();
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("topTransitLines", topTransitLines);
            request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
            return;
        }

        // Default fallback (optional)
        else {
            response.sendRedirect("adminDashboard.jsp");
        }
    }
}
