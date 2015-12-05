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
    
    public String getSessionUser(String sessId) throws SQLException{
        String query = "SELECT U.dir FROM utente U NATURAL JOIN sessioni S WHERE S.id=?";
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
    
    public String getTable(String table) throws SQLException{
        String tab = "";
        String query = "SELECT * FROM " + table;
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
                tab = "<table id='table_" + table + "' border=1>";
                
                /*Draw the column's names.*/
                tab += "<tr>";
                for(i = 1; i <= count; i++)
                    tab += "<td>" + rsmd.getColumnName(i) + "</td>";

                tab += "</tr>";

                /*Set the result set to the first row and draw all the rows.*/
                rs.beforeFirst();
                
                while(rs.next()){
                    tab += "<tr>";
                    for(i = 1; i <= count; i++)
                        tab += "<td>" + rs.getString(rsmd.getColumnName(i)) + "</td>";

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
}
