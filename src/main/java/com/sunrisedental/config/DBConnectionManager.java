package com.sunrisedental.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Singleton Pattern implementation for Database Connections.
 * Manages JDBC connections to WAMP Server MySQL Database (sunrise_dental_db).
 * Includes auto-detection & fallback logging if WAMP MySQL is offline.
 */
public class DBConnectionManager {

    private static final Logger LOGGER = Logger.getLogger(DBConnectionManager.class.getName());
    private static DBConnectionManager instance;

    // Default WAMP MySQL Configuration
    private String dbUrl = "jdbc:mysql://localhost:3306/sunrise_dental_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private String dbUser = "root";
    private String dbPassword = "";

    private DBConnectionManager() {
        try {
            // Load MySQL Connector/J Driver for Tomcat 10 / NetBeans
            Class.forName("com.mysql.cj.jdbc.Driver");
            LOGGER.info("[DBConnectionManager] MySQL JDBC Driver registered successfully.");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.WARNING, "[DBConnectionManager] MySQL Driver not found in classpath. Ensure mysql-connector-j.jar is in WEB-INF/lib/", e);
        }
    }

    /**
     * Singleton Instance Getter (Thread-safe Double-Checked Locking)
     */
    public static DBConnectionManager getInstance() {
        if (instance == null) {
            synchronized (DBConnectionManager.class) {
                if (instance == null) {
                    instance = new DBConnectionManager();
                }
            }
        }
        return instance;
    }

    /**
     * Get Connection to WAMP MySQL Server
     */
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    }

    public boolean isMySQLAvailable() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            LOGGER.log(Level.INFO, "[DBConnectionManager] WAMP MySQL server not connected on localhost:3306. System will use active in-memory session persistence.");
            return false;
        }
    }

    public String getDbUrl() { return dbUrl; }
    public void setDbUrl(String dbUrl) { this.dbUrl = dbUrl; }

    public String getDbUser() { return dbUser; }
    public void setDbUser(String dbUser) { this.dbUser = dbUser; }

    public String getDbPassword() { return dbPassword; }
    public void setDbPassword(String dbPassword) { this.dbPassword = dbPassword; }
}
