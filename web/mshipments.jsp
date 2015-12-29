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
        <link rel="stylesheet" type="text/css" href="css/style.css" />
        <link rel="icon" href="images/favicon.ico" type="favicon" sizes="16x16" />
        <%@page import="java.sql.*" %>
        <%@page import="log15.*" %>
        <%@page import="javax.servlet.http.Cookie" %>
        <%!
            DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
            String userType = null;
            String username = null;
            String logTime = null;
        %>
        <%
            Cookie[] cookies = request.getCookies();
            
            for(Cookie cookie : cookies)
                if(cookie.getName().equals("session")) {
                    userType = interrogator.getSessionUser(cookie.getValue());
                    username = interrogator.getUsernameFromSession(cookie.getValue());
                    logTime = interrogator.getLogTimeFromSession(cookie.getValue());
                }
            
            if(userType == null){
                response.setStatus(302);
                response.setHeader("location", "index.jsp");
            }
            else if (userType.equals("Driver")){
                response.setStatus(302);
                response.setHeader("location", "driver.jsp");
            }
        %>
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
        <style>
            .selected{
                background-color: lightgreen;
            }
            
            .row{
                cursor: pointer;
            }
        </style>
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
        <header class="Top">
            <table style="width: 100%; padding: 0px;">
                <tr>
                    <td style="width: 5%;"><a href="admin.jsp"><img src="images/logo.png" onmouseover="this.src='images/logo_on.png'" onmouseout="this.src='images/logo.png'" alt="Logo" /></a></td>
                    <td style="width: 75%; text-align: center;">
                        <nav class="Nav">
                            <ul>
                                <li><a href="mcustomers.jsp">Gestione Clienti</a></li>
                                <li><a href="mdrivers.jsp">Gestione Autisti</a></li>
                                <li><a href="mvehicles.jsp">Gestione Veicoli</a></li>
                                <li><a href="mshipments.jsp">Gestione Spedizioni</a></li>
                            </ul>
                        </nav>
                    </td>
                    <td style="width: 15%; text-align: right;"><p>Benvenuto <b><%=username%></b><br /><i>Accesso effettuato alle <%=logTime%></i><br />(<a href='Logout?username=<%=username%>'> logout </a>)</p></td>
                </tr>
            </table>
        </header>
        <section class="Container">
            <header>
                GESTIONE SPEDIZIONI
            </header>
            <article>
                <div id="map" style="margin: 5% 20%;width: 60%; height: 500px;"></div>
                <% shipments = interrogator.getShipmentsTable(); %>
                <%=shipments%>
                <script>
                    $(".row").click(function(){
                        /*If the clicked row, is not the selected one, make it.*/
                        if(!$(this).hasClass("selected")){
                            var shipment = JSON.parse(this.children[6].innerHTML);
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
                <script>
                    /* Search function */
                    $("input[value='Cerca']").click(function(){
                        parameters = new Array(4);
                        inputs = $("tr td input[type='text']");
                        allNull = false;
                        
                        /*Store all the search parameters into array.*/
                        for(i = 0; i < inputs.length; i++){
                            val = $(inputs[i]).val();
                            
                            if(val != undefined && val != ""){
                                parameters[i] = val;
                                allNull = true;
                            }
                            else
                                parameters[i] = null;
                        }
                        
                        /*Select all the rows that contain an effective db row.*/
                        $rows = $(".row");
                        
                        /*If the search inputs contain nothings, show all the rows.*/
                        if(!allNull)
                            $rows.show(1000);
                        else{
                            /*Scroll all the rows.*/
                            for(i = 0; i < $rows.length; i++){
                                /*For all the rows, scroll all its children.*/
                                $td = $($rows[i]).children();
                                to_delete = false;

                                /*If a parameter does not match, hide that row.*/
                                for(j = 0; j < $td.length; j++)
                                    if(parameters[j] != null && parameters[j] != $($td[j+1]).text())
                                        to_delete = true;

                                if(to_delete)
                                    $($rows[i]).hide('slow');
                                else if(!to_delete && $($rows[i]).is(":hidden"))
                                    $($rows[i]).show('slow');
                            }
                        }
                    });
                </script>
                <%
                    }catch(SQLException e){%>
                    <p>Errore nel database</p>
                <%    }
                %>
            </article>
        </section>
    </body>
</html>
