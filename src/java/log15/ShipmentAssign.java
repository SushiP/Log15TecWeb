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
import javax.servlet.http.HttpSession;
import java.sql.*;

/**
 *
 * @author Giulio
 */
@WebServlet(name = "ShipmentAssign", urlPatterns = {"/ShipmentAssign"})
public class ShipmentAssign extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        int row = Integer.parseInt(request.getParameter("row"));
        
        try (PrintWriter out = response.getWriter()) {
            ResultSet rs = null;
            HttpSession sess = request.getSession();
            int i = 0;
            String obj = "";
            
            /* If no row has been checked, create the ResultSet and set it as session's attribute.*/
            if(row == 0){
                String query = "SELECT * FROM cliente C1 JOIN cliente C2 ON C1.sedeDestinazione = C2.sedePartenza "
                                + "WHERE DATEDIFF(C1.deadline, CURDATE()) <= 7 AND DATEDIFF(C2.deadline, CURDATE()) <= 7 "
                                + "AND C1.pesoMerce + C2.pesoMerce <= 35 ORDER BY C1.id";
                Statement st = new DBConnector().getConnection().createStatement();
                rs = st.executeQuery(query);
                
                sess.setAttribute("shipment_rs", rs);
            }
            /*Else get the table.*/
            else
                rs = (ResultSet)sess.getAttribute("shipment_rs");
            
            /*Until there is row or the row is not the chosen one.*/
            while(rs.next() && i < row)
                i++;
            
            /*If the row was finded, create the object for the route.*/
            if(i == row)
                obj = "{\"start\" : \"" + rs.getString("C1.sedePartenza") + "\", \"dest\" : \"" + rs.getString("C2.sedeDestinazione")
                        + "\", \"waypoints\" : [{\"location\" : \"" + rs.getString("C1.sedeDestinazione") + "\"}], \"customer1\" :"
                        + "{\"name\" : \"" + rs.getString("C1.nome") + "\", \"id\": \""+ rs.getString("C1.id") +"\"}, \"customer2\" :"
                        + "{\"name\" : \"" + rs.getString("C2.nome") + "\", \"id\": \""+ rs.getString("C2.id") +"\"},"
                        + "\"goods\" : \"" + (rs.getInt("C1.pesoMerce") + rs.getInt("C2.pesoMerce")) + "\"}";
            else
                obj = "null";
            
            out.println(obj);
            
        }catch(IOException e){
            System.out.println("Errore nella creazione dello stream di output: " + e.getMessage());
        }catch(SQLException e){
            System.out.println("Errore nell'accesso al db: " + e.getMessage());
        }
    }

}
