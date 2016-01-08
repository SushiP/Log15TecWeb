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
        <script src="search.js"></script>
        <script src="manageMap.js"></script>
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
        <%--Control if admin is correctly logged in.--%>
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
            else if (userType.equals("Autista")){
                response.setStatus(302);
                response.setHeader("location", "driver.jsp");
            }
        %>
        <% 
            DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
            String shipments = null;
            
            try{
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
            var polylines = [];
            var marker;
            var id, step, dist;
                
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
                                                icon: "images/marker.png"})
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
                GESTIONE SPEDIZIONI GIORNALIERE
            </header>
            <article>
                <div id="map" style="width: 1024px; height: 500px;"></div>
                <p id="error_message" style="color:red"></p>
                <%--Recover the table of problems.--%>
                <%
                    /*Create the table of the problems.*/
                    String table = "";
                    try{
                        String query1 = "SELECT * FROM logproblemi";
                        Statement st1 = new DBConnector().getConnection().createStatement();
                        ResultSet rs1 = st1.executeQuery(query1);                      
                        table = "<table id='logproblems' class='Table'>" +
                                "<thead><tr><td style='background-color: #F5F5F5;' colspan='3'>Log Problemi</td></tr></thead>"+
                                "<tbody>";
                        
                        while(rs1.next()){
                            table += "<tr class='" + rs1.getString("idAsse") + "' hidden>";
                            table += "<td>" + rs1.getString("idAsse") + "</td>";
                            table += "<td>" + rs1.getString("descrizione") + "</td>";
                            table += "<td>" + rs1.getString("ritardo") + "</td>";
                            table += "</tr>";
                        }
                        table += "</tbody></table>";
                    }catch(SQLException e){
                        out.println("<p style='color: red'>Errore recupero dati nel database</p>");
                    }
                %>
                <%=table%>              
                <br/>
                <br/>
                <% shipments = interrogator.getShipmentsTable(); %>
                <%=shipments%>
                <script>
                    $(".row").click(function(){
                        /*If the clicked row, is not the selected one, make it.*/
                        if(!$(this).hasClass("selected")){
                            var shipment = JSON.parse(this.children[7].innerHTML);
                            
                            /*Clear the error messages and make the clicked row the selected one.*/
                            $("#error_message").empty();
                            $(".selected").toggleClass("selected");
                            $(this).toggleClass("selected");
                            
                            /*Show only the problems of selected shipment.*/
                            $("#logproblems tbody > tr").hide("slow");
                            $("." + $(".selected input[name='id']").val()).show("slow");

                            /*If it is not the first selection, clear the previous one.*/
                            if(id)
                                window.clearInterval(id);
                            
                            /*Create the route*/
                            create_route(shipment.start, shipment.destination, shipment.waypoints, function(info, response){
                                /*Create the polyline and get the time passed from the start of the shipment.*/
                                var date = $(".selected td:nth(8)").text().replace(" ", "T");
                                var pol = create_polyline(response.routes[0]);
                                
                                /*If shipment is started put the marker in the approximate position.*/
                                if(date != null && date != "null"){
                                    var today = new Date();
                                    var start = new Date(date);
                                    /*Calculate the passed time plus the possible delay.*/
                                    var passedTime = Math.floor((today - start) / 1000) - calculate_delay();
                                    
                                    /*If the shipment is not yet end, make it moving.*/
                                    if(passedTime < info.duration()){
                                        /*Calculate the distance crossed and the step basing on the time passed.*/
                                        dist = passedTime / info.duration() * info.distance();
                                        step = (0.1 / (info.duration() - passedTime)) * (info.distance() - dist); 

                                        id = window.setInterval(function(){next_step(info, pol)}, 100);
                                    }
                                    else
                                        marker.setPosition(pol.GetPointAtDistance(pol.Distance()));
                                }
                                else{
                                    marker.setPosition(pol.GetPointAtDistance(0));
                                    $("#error_message").text("Assegnamento non ancora partito");
                                }
                            });
                        }
                    });
                    
                    function calculate_delay(){
                        var rows = $("#logproblems").children()[1].children;
                        var delay = 0;
                        
                        /*Calculate the total delay of all visible rows.*/
                        for (var i = 0; i < rows.length; i++)
                            if($(rows[i]).is(":visible"))
                                delay += parseInt(rows[i].children[2].innerHTML);
                        
                        return (delay * 60);
                    }
                    
                    /* Search function */
                    $("input[value='Cerca']").click(function(){
                        search("#search_row input[type='text']", "row")
                    });
                </script>
                <%
                    }catch(SQLException e){
                        System.out.println("Errore nel recupero dati:" + e.getMessage());
                %>      
                        <p>Errore nel database</p>
                <%  }
                %>
            </article>
        </section>
    </body>
</html>
