/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package log15;

import java.sql.*;

/**
 *
 * @author Giulio
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
    
    public String getTable(String table) throws SQLException{
        String tab = "";
        String query = "SELECT * FROM " + table;
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
                tab = "<table id='table_" + table + "' border=1 class='Table'>";
                
                /*Draw the column's names.*/
                tab += "<tr>";
                for(i = idStart; i <= count; i++) {
                    if (i == idStart)
                        tab += "<td></td>";
                    else
                        tab += "<td>" + rsmd.getColumnName(i-1) + "</td>";
                }
                tab += "<td>" + rsmd.getColumnName(i-1) + "</td><td></td>";
                tab += "</tr>";
                
                tab += "<tr><form action='#' method='get'>";
                for (i = idStart; i<= count; i++) {
                    if (i == idStart)
                        tab += "<td></td>";
                    else 
                        tab += "<td><input type='text' id='" + rsmd.getColumnName(i-1) + "' /></td>";
                }
                tab += "<td><input type='text' id='" + rsmd.getColumnName(i-1) + "' />";
                tab += "<td><input type='submit' name='search' value='Cerca' /></td>";
                tab += "</form></tr>";

                /*Set the result set to the first row and draw all the rows.*/
                rs.beforeFirst();
                
                while(rs.next()){
                    tab += "<tr><form action='#' method='post'>";
                    tab += "<td><input type='checkbox' name='sel[]' value='" + rs.getString(rsmd.getColumnName(1)) + "' </td>";
                    for(i = idStart; i <= count; i++)
                        tab += "<td>" + rs.getString(rsmd.getColumnName(i)) + "</td>";
                    tab += "<td><a href='#'><button>Modifica</button></a></td>";
                    tab += "</form></tr>";
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
}
