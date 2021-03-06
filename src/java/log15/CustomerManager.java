package log15;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.sql.*;
import java.util.Vector;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;

/**
 *
 * @authors Auriemma Mazzoccola Giulio, Maurizio Cimino
 */
@WebServlet(name = "CustomerManager", urlPatterns = {"/CustomerManager"})
public class CustomerManager extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("text/html;charset=UTF-8");
        Boolean success = false;
        String operation = request.getParameter("operation");
        response.setStatus(302);
        
        try{
            if (operation.equals("insert")) {
                setSessionAttributes(request);
                success = insertCustomer(request);
                
                if (success) {
                    clearSession(request);
                    response.setHeader("location", "mcustomers.jsp?query=success");
                }
                else
                    response.setHeader("location", "mcustomers.jsp?op=insert&query=fail");
            }
            else if (operation.equals("update")) {
                success = updateCustomer(request);
                if (success)
                    response.setHeader("location", "mcustomers.jsp?query=success");
                else {
                    response.setHeader("location", "mcustomers.jsp?op=update&id=" + request.getParameter("id") + "&query=fail");
                }
            }
            else if (operation.equals("delete")) {
                success = deleteCustomer(request);
                
                if (success)
                    response.setHeader("location", "mcustomers.jsp?query=success");
                else
                    response.setHeader("location", "mcustomers.jsp?query=fail");
            }
        } catch(SQLException e) {
            System.out.println("Errore nell'accesso al database." + e.getMessage());
        }
    }
    
    private boolean insertCustomer(HttpServletRequest request) throws SQLException {
        
        if (!checkFieldsInput(request.getParameter("nome"), request.getParameter("sedePartenza"), request.getParameter("sedeDestinazione"),
            request.getParameter("deadline")))
            return false;
        
        Connection conn = new DBConnector().getConnection();
        
        if (request.getParameter("tipo").equals("Veloce")) {
            String query = "INSERT INTO assegnamento(clienti, veicolo, autista, deadline, stato, percorso) VALUES (?, ?, ?, ?, 'In Preparazione', '{\"start\": " + request.getParameter("sedePartenza") + ", \"destination\": " + request.getParameter("sedeDestinazione") +  ", \"waypoints\": []}')";
            ShipmentManager shipment = new ShipmentManager();
            String veicolo = shipment.takeVehicle(Integer.parseInt(request.getParameter("pesoMerce")), request.getParameter("deadline"));
            String autista = shipment.takeDriver(request.getParameter("deadline"));
            PreparedStatement ps = conn.prepareStatement(query);
            
            ps.setString(1, request.getParameter("nome"));
            ps.setString(2, veicolo);
            ps.setString(3, autista);
            ps.setString(4, request.getParameter("deadline"));
            
            if (ps.executeUpdate() > 0)
                return true;
            else
                return false;
        } else {
            String query = "INSERT INTO cliente(nome, sedePartenza, sedeDestinazione, deadline, pesoMerce, tipo) VALUES(?,?,?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(query);

            ps.setString(1, request.getParameter("nome"));
            ps.setString(2, request.getParameter("sedePartenza"));
            ps.setString(3, request.getParameter("sedeDestinazione"));
            ps.setString(4, request.getParameter("deadline"));
            ps.setInt(5, Integer.parseInt(request.getParameter("pesoMerce")));
            ps.setString(6, request.getParameter("tipo"));

            if(ps.executeUpdate() > 0)
                return true;
            else
                return false;
        }
    }
    
    private boolean updateCustomer(HttpServletRequest request) throws SQLException {
        
        if (!checkFieldsUpdate(request.getParameter("nome"), request.getParameter("sedePartenza"), request.getParameter("sedeDestinazione"),
            request.getParameter("deadline"), request.getParameter("odeadline")))
            return false;
        
        Connection conn = new DBConnector().getConnection();
        String query = "UPDATE cliente SET nome = ?, sedePartenza = ?, sedeDestinazione = ?, deadline = ?,"
                + " pesoMerce = ?, tipo = ? WHERE id = ?";
        PreparedStatement ps = conn.prepareStatement(query);
        
        ps.setString(1, request.getParameter("nome"));
        ps.setString(2, request.getParameter("sedePartenza"));
        ps.setString(3, request.getParameter("sedeDestinazione"));
        ps.setString(4, request.getParameter("deadline"));
        ps.setInt(5, Integer.parseInt(request.getParameter("pesoMerce")));
        ps.setString(6, request.getParameter("tipo"));
        ps.setInt(7, Integer.parseInt(request.getParameter("id")));
        
        if(ps.executeUpdate() > 0)
            return true;
        else
            return false;
    }
    
    private boolean deleteCustomer(HttpServletRequest request) throws SQLException {
        Connection conn = new DBConnector().getConnection();
        int j = 0;
        String sids[] = request.getParameterValues("sel[]");
        
        if (sids == null)
            return false;
        else {
            Vector ids = new Vector(2);
            for (int i = 0; i < sids.length; i++)
                if (sids[i] != null)
                    ids.add(Integer.parseInt(sids[i]));

            String query = "DELETE FROM cliente WHERE id = ?";
            for (int i = 0; i < ids.size()-1; i++)
                query +=" OR id = ?";
            
            PreparedStatement ps = conn.prepareStatement(query);
            for (int i = 0; i < ids.size(); i++)
                ps.setInt(i+1, (int)ids.elementAt(i));

            if(ps.executeUpdate() > 0)
                return true;
            else
                return false;
        }
    }
    
    public boolean checkFieldsInput(String nome, String sedeP, String sedeD, String deadline) {
        if (!nome.equals(""))
            if (!sedeP.equals("") && sedeP.length() <= 50)
                if (!sedeD.equals("") && !sedeD.equals(sedeP) && sedeD.length() <= 50)
                    if (!deadline.equals("")) {
                        if (checkDateForInsert(deadline))
                                return true;
                        else
                            return false;
                    }
                    else
                        return false;
                else
                    return false;
            else
                return false;
        else
            return false;              
    }
    
    public boolean checkDateForInsert(String deadline) {
        SimpleDateFormat sdf = new SimpleDateFormat();
        sdf.applyPattern("yyy-MM-dd");
        String today = sdf.format(new Date());
        
        try {
            Date date1 = sdf.parse(today);
            Date date2 = sdf.parse(deadline);
            long diff = date2.getTime() - date1.getTime();
            diff = TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
            if (diff >= 7)
                return true;
            else
                return false;
        } catch (Exception e) {
            System.out.println("Errore nella data: " + e.getMessage());
            return false;
        }
    }
    
    public boolean checkFieldsUpdate(String nome, String sedeP, String sedeD, String deadline, String odeadline) {
        if (!nome.equals(""))
            if (!sedeP.equals(""))
                if (!sedeD.equals("") && !sedeD.equals(sedeP))
                    if (!deadline.equals("")) {
                        if (checkDateForUpdate(deadline, odeadline))
                                return true;
                        else
                            return false;
                    }
                    else
                        return false;
                else
                    return false;
            else
                return false;
        else
            return false;              
    }
    
    public boolean checkDateForUpdate(String deadline, String odeadline) {
        SimpleDateFormat sdf = new SimpleDateFormat();
        sdf.applyPattern("yyy-MM-dd");
        
        try {
            Date date1 = sdf.parse(odeadline);
            Date date2 = sdf.parse(deadline);
            long diff = date2.getTime() - date1.getTime();
            diff = TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
            if (diff >= 0)
                return true;
            else
                return false;
        } catch (Exception e) {
            System.out.println("Errore nella data: " + e.getMessage());
            return false;
        } 
    }
    
    private void setSessionAttributes(HttpServletRequest request) {
        HttpSession session = request.getSession();
        
        session.setAttribute("nome", request.getParameter("nome"));
        session.setAttribute("sedePartenza", request.getParameter("sedePartenza"));
        session.setAttribute("sedeDestinazione", request.getParameter("sedeDestinazione"));
        session.setAttribute("deadline", request.getParameter("deadline"));
        session.setAttribute("pesoMerce", request.getParameter("pesoMerce"));
        session.setAttribute("tipo", request.getParameter("tipo"));
    }
    
    protected void clearSession(HttpServletRequest request) {
    HttpSession session = request.getSession(false);
    if (session != null)
        session.invalidate();
    }
}
