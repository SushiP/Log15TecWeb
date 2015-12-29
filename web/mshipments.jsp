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
        <script src="http://www.geocodezip.com/scripts/v3_epoly.js" type="text/javascript"></script>
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
            var marker;
            var id, step, dist;
            
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
                /*Create the marker.*/
                marker = new google.maps.Marker({map: map,
                                                icon: "https://maps.google.com/mapfiles/kml/shapes/schools_maps.png"})
            }
            
            /*Draw the info of all the route's legs.*/
            function RouteInfo(route){
                var dist = 0;
                var dur = 0;
                
                if(route){
                    for(i = 0; i < route.legs.length; i++){
                        dist += route.legs[i].distance.value;
                        dur += route.legs[i].duration.value;
                    }
                }
                
                this.distance = function(){return dist;};
                
                this.duration = function(){return dur;};
                
                this.distance_text = function(){
                    var km = dist / 1000;
                    
                    return km + " km";
                };
                
                this.duration_text = function(){
                    return time_to_string(dur / 60);
                };
                
                /*Function to convert minutes to a time string*/
                function time_to_string(time){
                    var h = Math.floor(time/60);
                    var m = Math.floor(time % 60);

                    if(h < 10)
                        h = "0" + h;

                    if(m < 10)
                        m = "0" + m;

                    var str = h + ":" + m;

                    return str;
                }
            }
            
            /*Create routes.*/
            function create_route(origin, destination, waypoints){
                var request = {
                    origin: origin,
                    destination: destination,
                    waypoints: waypoints,
                    travelMode: google.maps.DirectionsTravelMode.DRIVING
                };
                
                directionsService.route(request, function(response, status){
                    if(status == google.maps.DirectionsStatus.OK){
                        var info = new RouteInfo(response.routes[0]);
                        directionsDisplay.setDirections(response);
                        
                        /*Create the polyline and get the time passed from the start of the shipment.*/
                        var pol = create_polyline(response.routes[0]);
                        var today = new Date();
                        var start = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 7, 0);
                        var passedTime = Math.floor((today - start) / 1000);
                        
                        /*If the shipment is not yet end, make it moving.*/
                        if(passedTime < info.duration()){
                            dist = passedTime / info.duration() * info.distance();
                            step = (0.1 / (info.duration() - passedTime)) * (info.distance() - dist); 
                            
                            id = window.setInterval(function(){next_step(info, pol)}, 100);
                        }
                        else{
                            marker.setPosition(pol.GetPointAtDistance(info.distance()));
                        }
                    }
                });
            }
            
            /*Create the polyline from a route.*/
            function create_polyline(route){
                var polyline = new google.maps.Polyline({
                                    path: []
                                });
                                
                var legs = route.legs;
          
                for (i=0;i<legs.length;i++) {
                    var steps = legs[i].steps;
                  
                    for (j=0;j<steps.length;j++) {
                        var nextSegment = steps[j].path;
                    
                        for (k=0;k<nextSegment.length;k++)
                            polyline.getPath().push(nextSegment[k]);
                    } 
                }
                return polyline;
            }
            
            /*Update the marker and calculate the next step.*/
            function next_step(info, pol){
                if(dist > info.distance())
                    marker.setPosition(pol.GetPointAtDistance(info.distance()));
                else{
                    marker.setPosition(pol.GetPointAtDistance(dist));
                    dist += step;
                }
            }
        </script>
    </head>
    <body onload="create_map();">
    <div id="map" style="background-color: black; width: 500px; height: 500px;">a</div>
    <% shipments = interrogator.getShipmentsTable(); %>
    <%=shipments%>
    <script>
        $(".row").click(function(){
            /*If the clicked row, is not the selected one, make it.*/
            if(!$(this).hasClass("selected")){
                var shipment = JSON.parse(this.children[5].innerHTML);
                $(".selected").toggleClass("selected");
                $(this).toggleClass("selected");
                
                /*If it is not the first selection, clear the previous one.*/
                if(id)
                    window.clearInterval(id);
                
                /*Create the route*/
                create_route(shipment.start, shipment.destination, shipment.waypoints);
            }
        });
    </script>
    <%
        }catch(SQLException e){%>
        <p>Errore nel database</p>
    <%    }
    %>
    </body>
</html>
