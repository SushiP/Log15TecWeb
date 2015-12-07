package log15;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;
import java.util.Vector;

/**
 *
 * @author Giulio
 */
@WebServlet(name = "CustomerManager", urlPatterns = {"/CustomerManager"})
public class CustomerManager extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        response.setContentType("text/html;charset=UTF-8");
        Boolean success = false;
        String operation = request.getParameter("operation");

        try{
            if(operation.equals("insert"))
                success = insertCustomer(request);
            else if(operation.equals("update"))
                success = updateCustomer(request);
            else if(operation.equals("delete"))
                success = deleteCustomer(request);
        }catch(SQLException e){
            System.out.println("Errore nell'accesso al database.");
        }

        response.setStatus(302);
        if(success)
            response.setHeader("location", "mcustomers.jsp?query=success");
        else
            response.setHeader("location", "mcustomers.jsp?op=" + operation + "&query=fail");
    }
    
    private boolean insertCustomer(HttpServletRequest request) throws SQLException{
        Connection conn = new DBConnector().getConnection();
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
    
    private boolean updateCustomer(HttpServletRequest request) throws SQLException{
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
    
    private boolean deleteCustomer(HttpServletRequest request) throws SQLException{
        Connection conn = new DBConnector().getConnection();
        String query = "DELETE FROM cliente WHERE id = ?";
        PreparedStatement ps = conn.prepareStatement(query);
        
        ps.setInt(1, Integer.parseInt(request.getParameter("id")));
        
        if(ps.executeUpdate() > 0)
            return true;
        else
            return false;
    }
}
