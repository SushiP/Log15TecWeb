package log15;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.sql.*;
import java.util.Vector;

/**
 *
 * @author Maurizio
 */
@WebServlet(name = "DriversManager", urlPatterns = {"/DriversManager"})
public class DriversManager extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("text/html;charset=UTF-8");
        Boolean success = false;
        String operation = request.getParameter("operation");
        response.setStatus(302);
        
        try{
            if (operation.equals("insert")) {
                setSessionAttributes(request);
                success = insertDriver(request);
                
                if (success) {
                    clearSession(request);
                    response.setHeader("location", "mdrivers.jsp?query=success");
                }
                else
                    response.setHeader("location", "mdrivers.jsp?op=insert&query=fail");
            }
            else if (operation.equals("update")) {
                success = updateDriver(request);
                if (success)
                    response.setHeader("location", "mdrivers.jsp?query=success");
                else {
                    response.setHeader("location", "mdrivers.jsp?op=update&patente=" + request.getParameter("patente") + "&query=fail");
                }
            }
            else if (operation.equals("delete")) {
                success = deleteDriver(request);
                
                if (success)
                    response.setHeader("location", "mdrivers.jsp?query=success");
                else
                    response.setHeader("location", "mdrivers.jsp?query=fail");
            }
        } catch(SQLException e) {
            System.out.println("Errore nell'accesso al database." + e.getMessage());
        }
    }
    
    private boolean insertDriver(HttpServletRequest request) throws SQLException {
        
        if (!checkFields(request.getParameter("patente"), request.getParameter("nome"), request.getParameter("cognome")))
            return false;
        
        Connection conn = new DBConnector().getConnection();
        String query = "INSERT INTO autista(patente, nome, cognome, assenzeMensili) VALUES(UPPER(?),?,?,0)";
        PreparedStatement ps = conn.prepareStatement(query);
        
        ps.setString(1, request.getParameter("patente"));
        ps.setString(2, request.getParameter("nome"));
        ps.setString(3, request.getParameter("cognome"));
        
        if(ps.executeUpdate() > 0)
        {
            query = "INSERT INTO utente(username, password, dir) VALUES(?, MD5(?), 'Driver')";
            PreparedStatement ps2 = conn.prepareStatement(query);
            ps2.setString(1, request.getParameter("patente"));
            ps2.setString(2, request.getParameter("patente"));
            ps2.executeUpdate();
            
            return true;
        }
        else
            return false;
    }
    
    private boolean updateDriver(HttpServletRequest request) throws SQLException {
        
        if (!checkFields(request.getParameter("patente"), request.getParameter("nome"), request.getParameter("cognome")))
            return false;
        
        Connection conn = new DBConnector().getConnection();
        String query = "UPDATE autista SET nome = ?, cognome = ? WHERE patente = '" + request.getParameter("patente") + "'";
        PreparedStatement ps = conn.prepareStatement(query);
        
        ps.setString(1, request.getParameter("nome"));
        ps.setString(2, request.getParameter("cognome"));
        
        if(ps.executeUpdate() > 0)
            return true;
        else
            return false;
    }
    
    private boolean deleteDriver(HttpServletRequest request) throws SQLException {
        Connection conn = new DBConnector().getConnection();
        int j = 0;
        String sids[] = request.getParameterValues("sel[]");
        
        if (sids == null)
            return false;
        else {
            Vector ids = new Vector(2);
            for (int i = 0; i < sids.length; i++)
                if (sids[i] != null)
                    ids.add(sids[i]);

            String query = "DELETE FROM autista WHERE patente = ?";
            for (int i = 0; i < ids.size()-1; i++)
                query +=" OR patente = ?";
            
            PreparedStatement ps = conn.prepareStatement(query);
            for (int i = 0; i < ids.size(); i++)
                ps.setString(i+1, (String)ids.elementAt(i));

            if(ps.executeUpdate() > 0)
                return true;
            else
                return false;
        }
    }
    
    public boolean checkFields(String patente, String nome, String cognome) {
        if (!patente.equals(""))
            if (!nome.equals("") && nome.length() <= 15)
                if (!cognome.equals("") && cognome.length() <= 20)
                    if (patente.length() == 10)
                        return true;
                    else
                        return false;
                else
                    return false;
            else
                return false;
        else
            return false;
    }
    
    private void setSessionAttributes(HttpServletRequest request) {
        HttpSession session = request.getSession();
        
        session.setAttribute("patente", request.getParameter("patente"));
        session.setAttribute("nome", request.getParameter("nome"));
        session.setAttribute("cognome", request.getParameter("cognome"));
        session.setAttribute("assenzeMensili", request.getParameter("assenzeMensili"));
    }
    
    protected void clearSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null)
            session.invalidate();
    }
}
