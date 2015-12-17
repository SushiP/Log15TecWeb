<%-- 
    Document   : mshipments
    Created on : 16-dic-2015, 16.47.25
    Author     : Giulio
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Manage Shipments</title>
        <script src="https://maps.googleapis.com/maps/api/js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <%@page import="java.sql.*" %>
        <%@page import="log15.*" %>
        <% 
            DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
            String shipments = null;
        %>
        <%
            String query = "SELECT * FROM assegnamento WHERE deadline = curdate()";
            
            try{
                Statement st = new DBConnector().getConnection().createStatement();
                ResultSet rs = st.executeQuery(query);
        %>
        <script>
            var map;
            var directionsService = new google.maps.DirectionsService();
            var directionsDisplay = new google.maps.DirectionsRenderer();
            var routes = [];
            var polylines = [];
            
            <%while(rs.next()){%>
                routes.push(JSON.parse(<%=rs.getString("percorso")%>));
            <%}%>
                
            /*Create the google maps.*/
            function create_map(){
                var mapDiv = document.getElementById("map");
                var options = {
                    center : new google.maps.LatLng(42.674660, 12.795170),
                    zoom: 7,
                    mapTypeID: google.maps.MapTypeId.ROADMAP
                };

                map = new google.maps.Map(mapDiv, options);
                directionsDisplay.setMap(map); //Set map for Renderer object.
            }
            
            /*Create routes.*/
            function create_routes(){
                for(i = 0; i < routes.length; i++){
                    var request = {
                        origin: routes[i].start,
                        destination: routes[i].destination,
                        waypoints: routes[i].waypoints,
                        travelMode: google.maps.DirectionsTravelMode.DRIVING
                    };
                    
                    /*directionsService.route(request, function(response, status, i){
                        if (status == google.maps.DirectionsStatus.OK)
                            create_polyline(response.routes[0], i);
                    });*/
                }
            }
            
            /*function create_polyline(route, index){
                var color = Math.floor(Math.random() * 16777216);
                var polyline = new google.maps.Polyline({
                                    path: [],
                                    strokeColor: "#" + color.toString(16),
                                    strokeWeight: 3
                                });
                                
                var legs = route.legs;
          
                for (i=0;i<legs.length;i++) {
                    var steps = legs[i].steps;
                  
                    for (j=0;j<steps.length;j++) {
                        var nextSegment = steps[j].path;
                    
                        for (k=0;k<nextSegment.length;k++)
                            pol.getPath().push(nextSegment[k]);
                    } 
                }*/
        </script>
    </head>
    <body onload="create_map();">
    <div id="map" style="background-color: black; width: 500px; height: 500px;">a</div>
    <% shipments = interrogator.getShipmentsTable(); %>
    <%=shipments%>
    <%
        }catch(SQLException e){%>
        <p>Errore nel database</p>
    <%    }
    %>
    </body>
</html>
