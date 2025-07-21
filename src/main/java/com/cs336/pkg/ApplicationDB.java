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
    public boolean saveRep(String first_name, String last_name, String username, String password, String ssn) {
        Connection connection = getConnection();
        try {
        	String userQuery = "INSERT INTO users (username, password, first_name, last_name) " +
                    "VALUES (?, ?, ?, ?)";
            PreparedStatement userStmt = connection.prepareStatement(userQuery);
            userStmt.setString(3, username);
            userStmt.setString(4, password);
            userStmt.setString(1, first_name);
            userStmt.setString(2, last_name);
            userStmt.executeUpdate();
            
            String empQuery = "INSERT INTO employees (ssn, username, role) VALUES (?, ?, ?)";
            PreparedStatement empStmt = connection.prepareStatement(empQuery);
            empStmt.setString(1, ssn);
            empStmt.setString(2, username);
            empStmt.setString(3, "representative");
            empStmt.executeUpdate();
            
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete Representative
    public void deleteRep(String username) {
    	Connection connection = getConnection();
        try {
        	String empQuery = "DELETE FROM employees WHERE username=?";
            PreparedStatement empStmt = connection.prepareStatement(empQuery);
            empStmt.setString(1, username);
            empStmt.executeUpdate();
            
            String userQuery = "DELETE FROM User WHERE username = ?";
            PreparedStatement userStmt = connection.prepareStatement(userQuery);
            userStmt.setString(1, username);
            userStmt.executeUpdate();
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
    String query = "SELECT r.email AS customer_email, SUM(r.total_fare) AS total_revenue " +
                   "FROM reservations r " +
                   "JOIN customers c ON r.email = c.email " +
                   "GROUP BY r.email " +
                   "ORDER BY total_revenue DESC " +
                   "LIMIT 5";
    List<String[]> topCustomers = new ArrayList<>();
    try (Connection connection = getConnection();
         PreparedStatement stmt = connection.prepareStatement(query);
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
            String[] row = { rs.getString("customer_email"), rs.getString("total_revenue") };
            topCustomers.add(row);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return topCustomers;
}


    // Get Top 5 Most Active Transit Lines
    public List<String[]> getTopTransitLines() {
    String query = "SELECT ts.transit_line_name, COUNT(*) AS reservation_count " +
                   "FROM reservations r " +
                   "JOIN train_schedules ts ON r.schedule_id = ts.schedule_id " +
                   "GROUP BY ts.transit_line_name " +
                   "ORDER BY reservation_count DESC " +
                   "LIMIT 5";
    List<String[]> topTransitLines = new ArrayList<>();
    try (Connection connection = getConnection();
         PreparedStatement stmt = connection.prepareStatement(query);
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
            String[] row = { rs.getString("transit_line_name"), rs.getString("reservation_count") };
            topTransitLines.add(row);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return topTransitLines;
}



    // Get Reservations by Transit Line or Customer Name
    public List<String[]> getReservationsByCriteria(String transitLineId, String customerName) {
        List<String[]> results = new ArrayList<>();

        String sqlLineOnly =
          "SELECT r.reservation_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name, "
        + "       r.departure_date_time AS reservation_time, ts.transit_line_name AS transit_line "
        + "FROM reservations r "
        + "JOIN customers c ON r.email = c.email "
        + "JOIN users u ON c.username = u.username "
        + "JOIN train_schedules ts ON r.schedule_id = ts.schedule_id "
        + "WHERE ts.transit_line_name = ? "
        + "ORDER BY r.departure_date_time";

        String sqlNameOnly =
          "SELECT r.reservation_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name, "
        + "       r.departure_date_time AS reservation_time, ts.transit_line_name AS transit_line "
        + "FROM reservations r "
        + "JOIN customers c ON r.email = c.email "
        + "JOIN users u ON c.username = u.username "
        + "JOIN train_schedules ts ON r.schedule_id = ts.schedule_id "
        + "WHERE u.username LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ? "
        + "ORDER BY r.departure_date_time";

        String sqlBoth =
          "SELECT r.reservation_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name, "
        + "       r.departure_date_time AS reservation_time, ts.transit_line_name AS transit_line "
        + "FROM reservations r "
        + "JOIN customers c ON r.email = c.email "
        + "JOIN users u ON c.username = u.username "
        + "JOIN train_schedules ts ON r.schedule_id = ts.schedule_id "
        + "WHERE ts.transit_line_name = ? "
        + "  AND (u.username LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?) "
        + "ORDER BY r.departure_date_time";

        try (Connection con = getConnection()) {
            PreparedStatement ps;

            boolean hasLine = transitLineId   != null && !transitLineId.trim().isEmpty();
            boolean hasName = customerName    != null && !customerName.trim().isEmpty();

            if (hasLine && !hasName) {
                ps = con.prepareStatement(sqlLineOnly);
                ps.setString(1, transitLineId.trim());

            } else if (!hasLine && hasName) {
                ps = con.prepareStatement(sqlNameOnly);
                String p = "%" + customerName.trim() + "%";
                ps.setString(1, p);
                ps.setString(2, p);
                ps.setString(3, p);

            } else if (hasLine && hasName) {
                ps = con.prepareStatement(sqlBoth);
                ps.setString(1, transitLineId.trim());
                String p = "%" + customerName.trim() + "%";
                ps.setString(2, p);
                ps.setString(3, p);
                ps.setString(4, p);

            } else {
                // no criteria → return empty list
                return results;
            }

            // execute and auto-close result set
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(new String[]{
                        rs.getString("reservation_id"),
                        rs.getString("customer_name"),
                        rs.getString("reservation_time"),
                        rs.getString("transit_line")
                    });
                }
            }

        } catch (SQLException e) {
            // now all SQLExceptions (including close failures) are caught here
            e.printStackTrace();
        }

        return results;
    }

}
