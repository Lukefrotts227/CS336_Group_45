package com.cs336.pkg;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ApplicationDB {

    public ApplicationDB() {
    }

    public Connection getConnection() {
        String connectionUrl = "jdbc:mysql://localhost:3306/trainbookingdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        Connection connection = null;

        try {
            // Load JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            // Create a connection to the database
            connection = DriverManager.getConnection(connectionUrl, "jspuser", "jsp123");
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return connection;
    }

    public void closeConnection(Connection connection) {
        try {
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Save or Edit Representative
    public void saveRep(String id, String name, String email, String phone) {
        String query = "INSERT INTO customer_representatives (id, name, email, phone) " +
                       "VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE name=?, email=?, phone=?";
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, id);
            stmt.setString(2, name);
            stmt.setString(3, email);
            stmt.setString(4, phone);
            stmt.setString(5, name);
            stmt.setString(6, email);
            stmt.setString(7, phone);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Delete Representative
    public void deleteRep(String id) {
        String query = "DELETE FROM customer_representatives WHERE id=?";
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Get Monthly Sales Report
    public List<String[]> getMonthlySalesReport() {
        String query = "SELECT YEAR(reservation_date) AS year, MONTH(reservation_date) AS month, SUM(total_fare) AS total_revenue " +
                       "FROM reservations GROUP BY YEAR(reservation_date), MONTH(reservation_date) ORDER BY year, month";
        List<String[]> report = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                String[] row = { rs.getString("year"), rs.getString("month"), rs.getString("total_revenue") };
                report.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }

    // Get Revenue by Transit Line or Customer
    public String getRevenue(String transitLineId, String customerId) {
        String query = "SELECT SUM(r.total_fare) " +
        		"FROM reservations r " + 
        		"JOIN train_schedules ts ON r.schedule_id = ts.schedule_id" +
        		"JOIN transit_lines tl ON ts.transit_line_name = tl.name" +
        		"WHERE tl.name=? OR email=?";
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, transitLineId);
            stmt.setString(2, customerId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "0";
    }

    // Get Top 5 Revenue-Generating Customers
    public List<String[]> getTopCustomers() {
        String query = "SELECT email, SUM(total_fare) AS total_revenue FROM reservations GROUP BY customer_id ORDER BY total_revenue DESC LIMIT 5";
        List<String[]> topCustomers = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                String[] row = { rs.getString("email"), rs.getString("total_revenue") };
                topCustomers.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return topCustomers;
    }

    // Get Top 5 Most Active Transit Lines
    public List<String[]> getTopTransitLines() {
        String query = "SELECT transit_line_id, COUNT(*) AS reservation_count " +
                       "FROM reservations " +
                       "GROUP BY transit_line_id " +
                       "ORDER BY reservation_count DESC " +
                       "LIMIT 5";
        List<String[]> topTransitLines = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                String[] row = { rs.getString("transit_line_id"), rs.getString("reservation_count") };
                topTransitLines.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return topTransitLines;
    }


    // Get Reservations by Transit Line or Customer Name
    public List<String[]> getReservationsByCriteria(String transitLineId, String customerName) {
        String query = "SELECT reservation_id, customer_name, reservation_time, transit_line FROM reservations WHERE transit_line_id=? OR customer_name LIKE ?";
        List<String[]> reservations = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, transitLineId);
            stmt.setString(2, "%" + customerName + "%");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                String[] row = { rs.getString("reservation_id"), rs.getString("customer_name"), rs.getString("reservation_time"), rs.getString("transit_line") };
                reservations.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
}
