package log15;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;
import java.sql.*;
import java.util.UUID;


/**
 *
 * @author Maurizio, Giulio
 */
@WebServlet(name = "Login", urlPatterns = {"/Login"})

public class Login extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("text/html;charset=UTF-8");
        response.setStatus(302); /* Redirect */
        
        String username = (String) request.getParameter("username"); /* Get username parameter */
        String password = (String) request.getParameter("password"); /* Get password parameter */
        
        /* Get database connection */
        Connection connection = new DBConnector().getConnection();
        
        /* Check if this user exists */
        String query = "SELECT * FROM utente WHERE username = ? AND password = MD5(?)";
        try {
            PreparedStatement ps = connection.prepareStatement(query);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            
            /* if this user exists create a new session into the database and a new cookie */
            if (rs.next()) {
                /* Get if this user is admin or driver for the redirect */
                String Dir = rs.getString("dir");
                
                String uniqueID = UUID.randomUUID().toString();
                
                /* Create the new session */
                query = "INSERT INTO sessioni VALUES(MD5('"+ uniqueID + "'), NOW(), ?)";
                ps = connection.prepareStatement(query);
                ps.setString(1, username);
                ps.executeUpdate();
                
                /* Create the cookie for the session with the same MD5 written into database */
                query = "SELECT id FROM sessioni WHERE username = ?";
                ps = connection.prepareStatement(query);
                ps.setString(1, username);
                ResultSet rs2 = ps.executeQuery();
                
                rs2.next();
                Cookie cookie = new Cookie("session", rs2.getString("id"));
                cookie.setMaxAge(3600);
                response.addCookie(cookie);
                
                /* Redirect to the panel page */
                if (Dir.equals("Admin"))
                    response.setHeader("location", "admin.jsp");
                else
                    response.setHeader("location", "driver.jsp");
            } else
                /* Return back and manage the error */
                response.setHeader("location", "index.jsp?error=loginfailed");
        } catch (SQLException e) {
            System.out.println("Errore nel recupero degli utenti: " + e.getMessage());
        }
    }
}
