package log15;

import java.sql.Connection;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 *
 * @author Maurizio
 */
@WebServlet(name = "Report", urlPatterns = {"/Report"})
public class Report extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        response.setStatus(302);
        Connection conn = new DBConnector().getConnection();
        
        if (request.getParameter("Partenza") != null && request.getParameter("Partenza").equals("Partenza")) {
            int id = Integer.parseInt(request.getParameter("id"));
            
            try {
                String query = "UPDATE assegnamento SET oraPartenza = CURTIME() WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(query);
                ps.setInt(1, id);
                
                if(ps.executeUpdate() > 0)
                    response.setHeader("Location", "reports.jsp?query=success");
                else
                    response.setHeader("Location", "reports.jsp?query=fail");
            } catch (SQLException e) {
                response.setHeader("Location", "reports.jsp?query=fail");
            }
        }
        
        else if (request.getParameter("Arrivo") != null && request.getParameter("Arrivo").equals("Arrivo")) {
            int id = Integer.parseInt(request.getParameter("id"));
            
            try {
                String query = "UPDATE assegnamento SET oraArrivo = CURTIME() WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(query);
                ps.setInt(1, id);
                
                if(ps.executeUpdate() > 0)
                    response.setHeader("Location", "reports.jsp?query=success");
                else
                    response.setHeader("Location", "reports.jsp?query=fail");
            } catch (SQLException e) {
                response.setHeader("Location", "reports.jsp?query=fail");
            }
        }
        
        else if (request.getParameter("min") != null && request.getParameter("desc") != null && request.getParameter("id") != null) {
            int id = Integer.parseInt(request.getParameter("id"));
            int min = Integer.parseInt(request.getParameter("min"));
            String desc = request.getParameter("desc");
            
            try {
                String query = "INSERT INTO logproblemi VALUES(?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(query);
                ps.setInt(3, id);
                ps.setInt(2, min);
                ps.setString(1, desc);
                
                if (ps.executeUpdate() > 0)
                    response.setHeader("Location", "reports.jsp?query=success");
                else
                    response.setHeader("Location", "reports.jsp?query=fail");
            } catch (SQLException e) {
                response.setHeader("Location", "reports.jsp?query=fail");
            }
        }
    }

}
