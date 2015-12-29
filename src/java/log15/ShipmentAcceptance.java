/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package log15;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;
import java.sql.*;

/**
 *
 * @author Giulio
 */
@WebServlet(name = "ShipmentAcceptance", urlPatterns = {"/ShipmentAcceptance"})
public class ShipmentAcceptance extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    
    static final int maxAbsences = 3;
            
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        /*Get the parameters for the query.*/
        int shipment = Integer.parseInt(request.getParameter("shipment"));
        String action = request.getParameter("action");
        /*Set the redirect.*/
        response.setStatus(302);
        response.setHeader("location", "driver.jsp");
        
        /*Change the accettato attribute to 1.*/
        if(action.equals("Accetta")){
            String query = "UPDATE assegnamento SET accettato=1, stato='In Arrivo' WHERE id=?";
            try{
                PreparedStatement ps = new DBConnector().getConnection().prepareStatement(query);
                
                ps.setInt(1, shipment);
                ps.executeUpdate();
            }catch(SQLException e){
                System.out.println("Errore aggiornamento assegnamento: " + e.getMessage());
                response.setHeader("location", "driver.jsp?error=0");
            }
        }
        /*Else find a new driver and increase the number of absences of the driver.*/
        else{
            try{
                /*Recover the driver license of the connected driver.*/
                String dlicence = null;
                DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
                Cookie[] cookies = request.getCookies();

                for(Cookie cookie : cookies)
                        if(cookie.getName().equals("session"))
                            dlicence = interrogator.getUsernameFromSession(cookie.getValue());
                
                /*Be sure the driver has not the max number of absences.*/
                String query0 = "SELECT assenzeMensili FROM autista WHERE patente = '" + dlicence + "'";
                Statement psAbs = new DBConnector().getConnection().createStatement();
                ResultSet rs = psAbs.executeQuery(query0);

                if(rs.next() && rs.getInt("assenzeMensili") < maxAbsences){
                    /*Find a new driver and prepare the query if he is not null.*/
                    String newAutista = new ShipmentManager().takeDriver(request.getParameter("deadline"));
                    if(newAutista != null){
                        String query1 = "UPDATE assegnamento SET `autista`='" + newAutista + "' WHERE `id`=?";
                        String query2 = "UPDATE autista SET assenzeMensili = assenzeMensili+1 WHERE patente='" + dlicence + "'";
                        PreparedStatement ps = new DBConnector().getConnection().prepareStatement(query1);
                        Statement st = new DBConnector().getConnection().createStatement();

                        /*Set a new driver for the shipment.*/
                        ps.setInt(1, shipment);
                        ps.executeUpdate();

                        /*Update the absence of the driver.*/
                        st.executeUpdate(query2);
                    }
                    else
                        response.setHeader("location", "driver.jsp?error=2");
                }
                else
                    response.setHeader("location", "driver.jsp?error=1");
            }catch(SQLException e){
                System.out.println("Errore aggiornamento assegnamento: " + e.getMessage());
                response.setHeader("location", "driver.jsp?error=0");
            }    
        }
    }
}
