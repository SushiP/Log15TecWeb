package log15;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 *
 * @author Maurizio
 */
@WebServlet(name = "ShipmentManager", urlPatterns = {"/ShipmentManager"})
public class ShipmentManager extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.setStatus(302);
        /*Insert the data passed by post and create a new shipment.*/
        String route = request.getParameter("route");
        String customers = request.getParameter("customers");
        int weigth = Integer.parseInt(request.getParameter("pallet"));
        String deadline = request.getParameter("deadline");
        
        if(this.createShipment(customers, weigth, deadline, route)){
            response.setHeader("Location","admin.jsp?query=success");
            
            /*Update the customers inserted into new shipment.*/
            String []values = request.getParameter("id_customers").split(",");
            String query = "DELETE FROM cliente WHERE id = " + values[0];

            for(int i = 1; i < values.length; i++)
                query += " OR id = " + values[i];
            
            try(Statement st = new DBConnector().getConnection().createStatement()){
                st.executeUpdate(query);
            }catch(SQLException e){
                System.out.println("Errore nella modifica dei clienti: " + e.getMessage());
            }
        }
        else
            response.setHeader("Location","admin.jsp?query=fail");
    }
    
    public String takeDriver(String data) {
        Connection conn = new DBConnector().getConnection();
        String query = "SELECT A1.patente FROM autista AS A1 WHERE NOT EXISTS(SELECT A1.patente FROM autista AS A3 JOIN assegnamento AS A2 ON A3.patente = A2.autista WHERE A2.stato <> 'Consegnato' AND DATEDIFF(A2.deadline, ?) = 0 AND A3.patente = A1.patente) ORDER BY assenzeMensili DESC";
        
        try {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, data);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getString("patente");
            else 
                return null;
        } catch (SQLException e) {
            return null;
        }
    }
    
    public String takeVehicle(int weight) {
        Connection conn = new DBConnector().getConnection();
        String query = "SELECT V.targa from veicolo AS V WHERE NOT EXISTS(SELECT V.targa FROM veicolo AS V1 JOIN assegnamento AS A ON V1.targa = A.veicolo WHERE A.stato <> 'Consegnato' AND V1.targa = V.targa) AND ? <= V.capacita ORDER BY V.capacita ASC";
        
        try {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, weight);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getString("targa");
            else
                return null;
        } catch (SQLException e) {
            return null;
        }
    }
    
    private boolean insertShipment(String customers, String veicolo, String autista, String deadline, String percorso) {
        Connection conn = new DBConnector().getConnection();
        String query = "INSERT INTO assegnamento(clienti, veicolo, autista, deadline, stato, percorso) VALUES (?, ?, ?, ?, 'In Preparazione', ?)";
        
        try {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, customers);
            ps.setString(2, veicolo);
            ps.setString(3, autista);
            ps.setString(4, deadline);
            ps.setString(5, percorso);
            if(ps.executeUpdate() > 0)
                return true;
            else
                return false;
        } catch (SQLException e) { System.out.println(e.getMessage());
            return false;
        }
    }
    
    private boolean createShipment(String customers, int weight, String deadline, String percorso) {
        String veicolo = takeVehicle(weight);
        String autista = takeDriver(deadline);
        if (insertShipment(customers, veicolo, autista, deadline, percorso))
            return true;
        else
            return false;
    }
}
