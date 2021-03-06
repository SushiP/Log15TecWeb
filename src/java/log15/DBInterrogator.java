/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package log15;

import java.sql.*;

/**
 *
 * @authors Auriemma Mazzoccola Giulio, Maurizio Cimino
 */
public class DBInterrogator {
    private Connection connection = null;
    
    public DBInterrogator(Connection connection){
        this.connection = connection;
    }
    
    public String getSessionUser(String sessId) throws SQLException {
        String query = "SELECT U.dir FROM utente U NATURAL JOIN sessioni S WHERE S.id = ?";
        
        try{
            PreparedStatement ps = connection.prepareStatement(query);
            ps.setString(1, sessId);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next())
                return rs.getString("dir");
            else
                return null;
            
        }catch(SQLException e){
            throw(e);
        }
    }
    
    public String getUsernameFromSession(String sessId) throws SQLException {
        String query = "SELECT U.username FROM utente U NATURAL JOIN sessioni S WHERE S.id = ?";
        
        try {
            PreparedStatement ps = connection.prepareStatement(query);
            ps.setString(1, sessId);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next())
                return rs.getString("username");
            else
                return null;
        } catch (SQLException e) {
            throw(e);
        }
    }
    
    public String getDriverFromSession (String sessId) throws SQLException {
        String query = "SELECT autista.Nome FROM autista, sessioni, utente WHERE sessioni.id = ? AND autista.patente = utente.username AND utente.username = sessioni.username";
        
        try {
            PreparedStatement ps = connection.prepareStatement(query);
            ps.setString(1, sessId);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next())
                return rs.getString("nome");
            else
                return null;
        } catch (SQLException e) {
            throw(e);
        }
    }
    
        public String getLogTimeFromSession(String sessId) throws SQLException {
        String query = "SELECT logTime FROM sessioni S WHERE S.id = ?";
        
        try {
            PreparedStatement ps = connection.prepareStatement(query);
            ps.setString(1, sessId);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next())
                return rs.getString("logTime");
            else
                return null;
        } catch (SQLException e) {
            throw(e);
        }
    }
    
    public String getCustomersTable() throws SQLException{
        String tab = "";
        String query = "SELECT * FROM cliente";
        int idStart = 1;
        
        try{
            Statement stat = connection.createStatement();
            ResultSet rs = stat.executeQuery(query);
            
            /*If the table exists.*/
            if(rs.next()){
                /*Get the table meta data.*/
                ResultSetMetaData rsmd = rs.getMetaData();
                int count = rsmd.getColumnCount();
                int i;

                /* If exists id field, jump it while printing the table */
                if (rsmd.getColumnName(1).equals("id"))
                    idStart++;
                
                /*Start to draw the table tag.*/
                tab = "<table id='table_customers' class='Table'>";
                
                /*Draw the column's names.*/
                tab += "<tr style='background-color: #F5F5F5;'>";
                tab += "<td></td><td>Nome</td><td>Sede Partenza</td><td>Sede Destinazione</td><td>Deadline</td><td>Peso Merce</td><td>Tipo Spedizione</td><td></td>";
                tab += "</tr>";
                
                tab += "<tr id='search_row'>";
                for (i = idStart; i<= count; i++) {
                    if (i == idStart)
                        tab += "<td></td>";
                    else 
                        tab += "<td><input type='text' name='" + rsmd.getColumnName(i-1) + "' /></td>";
                }
                tab += "<td><input type='text' id='" + rsmd.getColumnName(i-1) + "' />";
                tab += "<td><input class='Button' style='height: 30px; width: 80px;' type='submit' name='search' value='Cerca' /></td>";
                tab += "</tr>";

                /*Set the result set to the first row and draw all the rows.*/
                rs.beforeFirst();
                
                while(rs.next()){
                    tab += "<tr class ='row'><td><form method='post' action='CustomerManager?operation=delete'>"
                            + "<input type='hidden' name='id' value='" + rs.getString(rsmd.getColumnName(1)) + "' /><input type='checkbox' name='sel[]' value='" + rs.getString(rsmd.getColumnName(1)) + "' /></td>";
                    for(i = idStart; i <= count; i++)
                        tab += "<td>" + rs.getString(rsmd.getColumnName(i)) + "</td>";
                    tab += "<td><a href='mcustomers.jsp?op=update&id=" + rs.getString(rsmd.getColumnName(1)) + "'><button style='height: 30px; width: 80px;' class='Button' type='Button'>Modifica</button></a></td>";
                    tab += "</tr>";
                }
                
                /*Close table tag.*/
                tab += "</table><input class='Button' style='height: 30px; width: 100px;' type='submit' name='del' value='Cancella' /></form>";
            }
        }
        catch(SQLException e){
            throw(e);
        }
        return tab;
    }
    
    public String getDriversTable() throws SQLException{
        String tab = "";
        String query = "SELECT * FROM autista";
        
        try{
            Statement stat = connection.createStatement();
            ResultSet rs = stat.executeQuery(query);
            
            /*If the table exists.*/
            if(rs.next()){
                /*Get the table meta data.*/
                ResultSetMetaData rsmd = rs.getMetaData();
                int count = rsmd.getColumnCount();
                int i;
                
                /*Start to draw the table tag.*/
                tab = "<table id='table_drivers' class='Table'>";
                
                /*Draw the column's names.*/
                tab += "<tr style='background-color: #F5F5F5;'>";
                tab += "<td></td><td>Patente</td><td>Nome</td><td>Cognome</td><td>Assenze Mensili</td><td></td>";
                tab += "</tr>";
                
                tab += "<tr id='search_row'>";
                tab += "<td></td>";
                for (i = 1; i <= count; i++) 
                        tab += "<td><input type='text' name='" + rsmd.getColumnName(i) + "' /></td>";
                tab += "<td><input class='Button' style='height: 30px; width: 80px;' type='submit' name='search' value='Cerca' /></td>";
                tab += "</tr>";

                /*Set the result set to the first row and draw all the rows.*/
                rs.beforeFirst();
                
                while(rs.next()){
                    tab += "<tr class ='row'><td><form method='post' action='DriversManager?operation=delete'>"
                            + "<input type='checkbox' name='sel[]' value='" + rs.getString(rsmd.getColumnName(1)) + "' </td>";
                    for(i = 1; i <= count; i++)
                        tab += "<td>" + rs.getString(rsmd.getColumnName(i)) + "</td>";
                    tab += "<td><a href='mdrivers.jsp?op=update&patente=" + rs.getString(rsmd.getColumnName(1)) + "'><button style='height: 30px; width: 80px;' class='Button' type='Button'>Modifica</button></a></td>";
                    tab += "</tr>";
                }
                
                /*Close table tag.*/
                tab += "</table><input class='Button' style='height: 30px; width: 100px;' type='submit' name='del' value='Cancella' /></form>";
            }
        }
        catch(SQLException e){
            throw(e);
        }
        return tab;
    }
    
    public String getVehicleTable() throws SQLException{
        String tab = "";
        String query = "SELECT * FROM veicolo";
        
        try{
            Statement stat = connection.createStatement();
            ResultSet rs = stat.executeQuery(query);
            
            /*If the table exists.*/
            if(rs.next()){
                /*Get the table meta data.*/
                ResultSetMetaData rsmd = rs.getMetaData();
                int count = rsmd.getColumnCount();
                int i;
                
                /*Start to draw the table tag.*/
                tab = "<table id='table_vehicles' class='Table'>";
                
                /*Draw the column's names.*/
                tab += "<tr style='background-color: #F5F5F5;'>";
                tab += "<td></td><td>Targa</td><td>Anno Registrazione</td><td>Carburante</td><td>Marca</td><td>Capacità</td><td></td>";
                tab += "</tr>";
                
                tab += "<tr id='search_row'>";
                tab += "<td></td>";
                for (i = 1; i <= count; i++) 
                        tab += "<td><input type='text' name='" + rsmd.getColumnName(i) + "' /></td>";
                tab += "<td><input class='Button' style='height: 30px; width: 80px;' type='submit' name='search' value='Cerca' /></td>";
                tab += "</tr>";

                /*Set the result set to the first row and draw all the rows.*/
                rs.beforeFirst();
                
                while(rs.next()){
                    tab += "<tr class ='row'><td><form method='post' action='VehicleManager?operation=delete'>"
                            + "<input type='checkbox' name='sel[]' value='" + rs.getString(rsmd.getColumnName(1)) + "' </td>";
                    for(i = 1; i <= count; i++)
                        tab += "<td>" + rs.getString(rsmd.getColumnName(i)) + "</td>";
                    tab += "<td><a href='mvehicles.jsp?op=update&targa=" + rs.getString(rsmd.getColumnName(1)) + "'><button style='height: 30px; width: 80px;' class='Button' type='Button'>Modifica</button></a></td>";
                    tab += "</tr>";
                }
                
                /*Close table tag.*/
                tab += "</table><input class='Button' style='height: 30px; width: 100px;' type='submit' name='del' value='Cancella' /></form>";
            }
        }
        catch(SQLException e){
            throw(e);
        }
        return tab;
    }
    
    public String getShipmentsTable() throws SQLException {
        String tab = "";
        String query = "SELECT * FROM assegnamento WHERE deadline = curdate()";
        int idStart = 1;
        
        try{
            Statement stat = connection.createStatement();
            ResultSet rs = stat.executeQuery(query);
            
            /*If the table exists.*/
            if(rs.next()){
                /*Get the table meta data.*/
                ResultSetMetaData rsmd = rs.getMetaData();
                int i=1;
                
                /*Start to draw the table tag.*/
                tab = "<table id='table_customers' class='Table'>";
                
                /*Draw the column's names.*/
                tab += "<tr style='background-color: #F5F5F5;'>";
                tab += "<td></td><td>Clienti</td><td>Veicolo</td><td>Autista</td><td>Deadline</td><td>Stato</td><td></td>";
                tab += "</tr>";
                
                tab += "<tr id='search_row'><td></td>";
                tab += "<td><input type='text' name='clienti' /></td>";
                tab += "<td><input type='text' name='veicolo' /></td>";
                tab += "<td><input type='text' name='autista' /></td>";
                tab += "<td><input type='text' name='deadline' /></td>";
                tab += "<td><input type='text' name='stato' /></td>";
                tab += "<td><input class='Button' style='height: 30px; width: 80px;' type='submit' name='search' value='Cerca' /></td>";
                tab += "</tr>";

                /*Set the result set to the first row and draw all the rows.*/
                rs.beforeFirst();
                
                while(rs.next()){
                    tab += "<tr class ='row'><td>"
                            + "<input type='hidden' name='id' value='" + rs.getString(rsmd.getColumnName(1)) + "' /></td>";

                    tab += "<td>" + rs.getString(rsmd.getColumnName(2)) + "</td>";
                    tab += "<td>" + rs.getString(rsmd.getColumnName(3)) + "</td>";
                    tab += "<td>" + rs.getString(rsmd.getColumnName(4)) + "</td>";
                    tab += "<td>" + rs.getString(rsmd.getColumnName(5)) + "</td>";
                    tab += "<td>" + rs.getString(rsmd.getColumnName(7)) + "</td><td></td>";
                    tab += "<td hidden>" + rs.getString(rsmd.getColumnName(8)) + "</td>";
                    tab += "<td hidden>" + rs.getString(rsmd.getColumnName(9)) + "</td>";
                    tab += "<td hidden>" + rs.getString(rsmd.getColumnName(10)) + "</td>";
                    tab += "</tr>";
                }
                
                /*Close table tag.*/
                tab += "</table>";
            }
        }
        catch(SQLException e){
            throw(e);
        }
        return tab;
    }
    
    public String[] getCustomerRow(String id) throws SQLException {
        String[] Ris = new String[8];
        
        String query = "SELECT * FROM cliente WHERE id = ?";
        PreparedStatement ps = connection.prepareStatement(query);
        ps.setString(1, id);
        ResultSet rs = ps.executeQuery();
        ResultSetMetaData rsmd = rs.getMetaData();
        int count = rsmd.getColumnCount();
        
        if (rs.next())
            for (int i = 1; i <= count; i++)
                Ris[i] = rs.getString(rsmd.getColumnName(i));
        
        return Ris;
    }
    
    public String[] getDriverRow(String patente) throws SQLException {
        String[] Ris = new String[5];
        
        String query = "SELECT * FROM autista WHERE patente = '" + patente + "'";
        PreparedStatement ps = connection.prepareStatement(query);
        /*ps.setString(1, query);*/
        ResultSet rs = ps.executeQuery();
        ResultSetMetaData rsmd = rs.getMetaData();
        int count = rsmd.getColumnCount();
        
        if (rs.next())
            for (int i = 1; i <= count; i++)
                Ris[i] = rs.getString(rsmd.getColumnName(i));
        
        return Ris;
    }
    
    public String[] getVehicleRow(String targa) throws SQLException {
        String[] Ris = new String[6];
        
        String query = "SELECT * FROM veicolo WHERE targa = '" + targa + "'";
        PreparedStatement ps = connection.prepareStatement(query);
        /*ps.setString(1, query);*/
        ResultSet rs = ps.executeQuery();
        ResultSetMetaData rsmd = rs.getMetaData();
        int count = rsmd.getColumnCount();
        
        if (rs.next())
            for (int i = 1; i <= count; i++)
                Ris[i] = rs.getString(rsmd.getColumnName(i));
        
        return Ris;
    }
}
