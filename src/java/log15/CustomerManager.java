/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package log15;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 *
 * @author Giulio
 */
@WebServlet(name = "CustomerManager", urlPatterns = {"/CustomerManager"})
public class CustomerManager extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            Boolean success = false;
            String operation = request.getParameter("operation");
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CustomerManager</title>");            
            out.println("</head>");
            out.println("<body>");
            
            try{
                if(operation.equals("insert"))
                    success = insertCustomer(request);
                else if(operation.equals("update"))
                    success = updateCustomer(request);
                else if(operation.equals("delete"))
                    success = deleteCustomer(request);
            }catch(SQLException e){
                out.println("Errore nell'accesso al database.");
            }
            
            if(success)
                out.println("<h3>Operazione avvenuta con successo</h3>");
            else
                out.println("<h3>Operazione non riuscita</h3>");
            
            out.println("<a href='index.jsp'>Torna alla pagina principale </a>");
            out.println("</body>");
            out.println("</html>");
        }
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
