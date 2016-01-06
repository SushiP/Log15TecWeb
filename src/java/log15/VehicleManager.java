package log15;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.sql.*;
import java.util.Vector;
import java.util.Calendar;
import java.util.GregorianCalendar;

/**
 *
 * @authors Auriemma Mazzoccola Giulio, Maurizio Cimino
 */
@WebServlet(name = "VehicleManager", urlPatterns = {"/VehicleManager"})
public class VehicleManager extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("text/html;charset=UTF-8");
        Boolean success = false;
        String operation = request.getParameter("operation");
        response.setStatus(302);
        
        try{
            if (operation.equals("insert")) {
                setSessionAttributes(request);
                success = insertVehicle(request);
                
                if (success) {
                    clearSession(request);
                    response.setHeader("location", "mvehicles.jsp?query=success");
                }
                else
                    response.setHeader("location", "mvehicles.jsp?op=insert&query=fail");
            }
            else if (operation.equals("update")) {
                success = updateVehicle(request);
                if (success)
                    response.setHeader("location", "mvehicles.jsp?query=success");
                else {
                    response.setHeader("location", "mvehicles.jsp?op=update&targa=" + request.getParameter("targa") + "&query=fail");
                }
            }
            else if (operation.equals("delete")) {
                success = deleteVehicle(request);
                
                if (success)
                    response.setHeader("location", "mvehicles.jsp?query=success");
                else
                    response.setHeader("location", "mvehicles.jsp?query=fail");
            }
        } catch(SQLException e) {
            System.out.println("Errore nell'accesso al database." + e.getMessage());
        }
    }
    
    private boolean insertVehicle(HttpServletRequest request) throws SQLException {
        
        if (!checkFields(request.getParameter("targa"), request.getParameter("annoRegistrazione"), request.getParameter("carburante"),
                         request.getParameter("marca")))
            return false;
        
        Connection conn = new DBConnector().getConnection();
        String query = "INSERT INTO veicolo(targa, annoRegistrazione, carburante, marca, capacita) VALUES(UPPER(?),?,?,?,?)";
        PreparedStatement ps = conn.prepareStatement(query);
        
        ps.setString(1, request.getParameter("targa"));
        ps.setInt(2, Integer.parseInt(request.getParameter("annoRegistrazione")));
        ps.setString(3, request.getParameter("carburante"));
        ps.setString(4, request.getParameter("marca"));
        ps.setInt(5, Integer.parseInt(request.getParameter("capacita")));
        
        if(ps.executeUpdate() > 0)
            return true;
        else
            return false;
    }
    
    private boolean updateVehicle(HttpServletRequest request) throws SQLException {
        
        if (!checkFields(request.getParameter("targa"), request.getParameter("annoRegistrazione"), request.getParameter("carburante"),
                         request.getParameter("marca")))
            return false;
        
        Connection conn = new DBConnector().getConnection();
        String query = "UPDATE veicolo SET annoRegistrazione = ?, carburante = ?, marca = ?, capacita = ? WHERE targa = '" + request.getParameter("targa") + "'";
        PreparedStatement ps = conn.prepareStatement(query);
        
        ps.setInt(1, Integer.parseInt(request.getParameter("annoRegistrazione")));
        ps.setString(2, request.getParameter("carburante"));
        ps.setString(3, request.getParameter("marca"));
        ps.setString(4, request.getParameter("capacita"));
        
        if(ps.executeUpdate() > 0)
            return true;
        else
            return false;
    }
    
    private boolean deleteVehicle(HttpServletRequest request) throws SQLException {
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

            String query = "DELETE FROM veicolo WHERE targa = ?";
            for (int i = 0; i < ids.size()-1; i++)
                query +=" OR targa = ?";
            
            PreparedStatement ps = conn.prepareStatement(query);
            for (int i = 0; i < ids.size(); i++)
                ps.setString(i+1, (String)ids.elementAt(i));

            try {
                ps.executeUpdate();
                return true;
            } catch (SQLException e) {
                return false;
            }
        }
    }
    
    public boolean checkFields(String targa, String annoRegistrazione, String carburante, String marca) {
        if (!targa.equals("") && targa.length() == 7)
            if (!annoRegistrazione.equals("")) {
                Calendar calendar = GregorianCalendar.getInstance();
                if (Integer.parseInt(annoRegistrazione) <= calendar.get((Calendar.YEAR)) && Integer.parseInt(annoRegistrazione) >= 1990)
                    if (!carburante.equals(""))
                        if (!marca.equals("") && marca.length() <= 50)
                            return true;
                        else
                            return false;
                    else
                        return false;
                else
                    return false;
            }
            else
                return false;
        else
            return false;
    }
    
    private void setSessionAttributes(HttpServletRequest request) {
        HttpSession session = request.getSession();
        
        session.setAttribute("targa", request.getParameter("targa"));
        session.setAttribute("annoRegistrazione", request.getParameter("annoRegistrazione"));
        session.setAttribute("carburante", request.getParameter("carburante"));
        session.setAttribute("marca", request.getParameter("marca"));
        session.setAttribute("capacita", request.getParameter("capacita"));
    }
    
    protected void clearSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null)
            session.invalidate();
    }
}
