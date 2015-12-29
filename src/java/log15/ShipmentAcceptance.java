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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int shipment = Integer.parseInt(request.getParameter("shipment"));
        String action = request.getParameter("action");
        
        /*Change the accettato attribute to 1.*/
        if(action.equals("Accetta")){
            String query = "UPDATE assegnamento SET accettato=1 WHERE id=?";
            try{
                PreparedStatement ps = new DBConnector().getConnection().prepareStatement(query);
                
                ps.setInt(1, shipment);
                ps.executeUpdate();
            }catch(SQLException e){
                System.out.println("Errore aggiornamento assegnamento: " + e.getMessage());
            }
        }
        /*Else find a new driver and increase the number of absences of the driver.*/
        else{
            try{
                String dlicence = null;
                DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
                Cookie[] cookies = request.getCookies();

                for(Cookie cookie : cookies)
                    if(cookie.getName().equals("session"))
                        dlicence = interrogator.getUsernameFromSession(cookie.getValue());

                String newAutista = dlicence;
                String driver = new ShipmentManager().takeDriver();
                String query1 = "UPDATE assegnamento SET `autista`='" + newAutista + "' WHERE `id`=?";
                String query2 = "UPDATE autista SET assenzeMensili = assenzeMensili+1 WHERE patente='" + driver + "'";
                PreparedStatement ps = new DBConnector().getConnection().prepareStatement(query1);
                Statement st = new DBConnector().getConnection().createStatement();

                /*Set a new driver for the shipment.*/
                ps.setInt(1, shipment);
                ps.executeUpdate();
                
                /*Update the absence of the driver.*/
                st.executeUpdate(query2);
            }catch(SQLException e){
                System.out.println("Errore aggiornamento assegnamento: " + e.getMessage());
            }    
        }
    }

}
