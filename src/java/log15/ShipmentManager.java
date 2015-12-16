package log15;

import java.io.PrintWriter;
import java.io.IOException;
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
        int weigth = Integer.parseInt(request.getParameter("pallet"));

        if(this.createShipment(weigth, "2015-12-23", "2015-12-23", "2015-12-23", route)){
            response.setHeader("Location","admin.jsp");
            
            /*Update the customers inserted into new shipment.*/
            String []values = request.getParameter("id_customers").split(", ");
            String query = "UPDATE cliente SET tipo = 'Assegna' WHERE id = " + values[0];

            for(int i = 1; i < values.length; i++)
                query += " OR id = " + values[i];

            try(Statement st = new DBConnector().getConnection().createStatement()){
                st.executeUpdate(query);
            }catch(SQLException e){
                System.out.println("Errore nella modifica dei clienti: " + e.getMessage());
            }
        }
        else
            response.setHeader("Location","admin.jsp?error=1");
    }
    
    private String takeDriver() {
        Connection conn = new DBConnector().getConnection();
        String query = "SELECT A.patente FROM autista AS A1 WHERE NOT EXISTS(SELECT A.patente FROM autista AS A1 JOIN assegnamento AS A2 ON A1.patente = A2.autista WHERE A2.stato <> 'Consegnato') ORDER BY assenzeMensili DESC";
        
        try {
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getString("patente");
            else 
                return null;
        } catch (SQLException e) {
            return null;
        }
    }
    
    private String takeVehicle(int weight) {
        Connection conn = new DBConnector().getConnection();
        String query = "SELECT V.targa from veicolo AS V WHERE NOT EXISTS(SELECT V.targa FROM veicolo AS V JOIN assegnamento AS A ON V.targa = A.veicolo WHERE A.stato <> 'Consegnato') AND ? <= V.capacita ORDER BY V.capacita ASC";
        
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
    
    private boolean insertShipment(String veicolo, String autista, String deadline, String partenza, String arrivo, String percorso) {
        Connection conn = new DBConnector().getConnection();
        String query = "INSERT INTO assegnamento(veicolo, autista, deadline, stato, partenza, arrivo, percorso) VALUES(?, ?, ?, 'In Preparazione', ?, ?, ?)";
        
        try {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, veicolo);
            ps.setString(2, autista);
            ps.setString(3, deadline);
            ps.setString(4, partenza);
            ps.setString(5, arrivo);
            ps.setString(6, percorso);
            if(ps.executeUpdate() > 0)
                return true;
            else
                return false;
        } catch (SQLException e) {
            return false;
        }
    }
    
    private boolean createShipment(int weight, String deadline, String partenza, String arrivo, String percorso) {
        String veicolo = takeVehicle(weight);
        String autista = takeDriver();
        if (insertShipment(veicolo, autista, deadline, partenza, arrivo, percorso))
            return true;
        else
            return false;
    }
}
