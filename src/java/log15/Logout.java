package log15;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;
import javax.servlet.http.Cookie;

/**
 *
 * @authors Auriemma Mazzoccola Giulio, Maurizio Cimino
 */
@WebServlet(name = "Logout", urlPatterns = {"/Logout"})
public class Logout extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        response.setStatus(302); /* Redirect */
        
        /* Get username passed through the url */
        String username = request.getParameter("username");
        
        if (username != null) {
             Connection connection = new DBConnector().getConnection(); /* Get database connection */
             
             /* Get the id's session of this user */
             String query = "SELECT id FROM sessioni WHERE username = ?";
             try {
                 PreparedStatement ps = connection.prepareStatement(query);
                 ps.setString(1, username);
                 ResultSet rs = ps.executeQuery();
                 
                 /* If this session exists */
                 if (rs.next()) {
                     String id = rs.getString("id");
                     
                     /* Delete this session from the database */
                     query = "DELETE FROM sessioni WHERE id = ?";
                     ps = connection.prepareStatement(query);
                     ps.setString(1, id);
                     ps.executeUpdate();
                     
                     /* Delete the cookie associated to this session */
                     Cookie[] cookies = request.getCookies();
                     for (Cookie cookie : cookies)
                         if (cookie.getName().equals("session") && cookie.getValue().equals(id))
                             cookie.setMaxAge(-1);
                 }
                 
                 /* Return to index.jsp - it will redirects to the right page the user */
                 response.setHeader("location", "index.jsp");
             } catch (SQLException e) {
                 System.out.println("Errore nel recupero delle sessioni: " + e.getMessage());
             }
        }
        else /* Return to index.jsp - it will redirects to the right page the user */
            response.setHeader("location", "index.jsp");
    }
}
