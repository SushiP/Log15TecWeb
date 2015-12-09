package log15;

import java.sql.DriverManager;
import java.sql.*;

/**
 *
 * @author Maurizio, Giulio
 */
public class DBConnector {
    /* Connection to database */
    static private Connection connection = null;
    
    public DBConnector() {
        if (connection == null) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                String connectionUrl = "jdbc:mysql://localhost:3306/log15";
                connection = DriverManager.getConnection(connectionUrl, "root", "1234");
            } catch (Exception e) {
                System.out.println("Errore nella connessione al database: " + e.getMessage());
            }
        }
    }
    
    public Connection getConnection() {
        return connection;
    }
}
