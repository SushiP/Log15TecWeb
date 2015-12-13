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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        
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
}
