<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Admin Panel</title>
        <script src="https://maps.googleapis.com/maps/api/js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <link rel="stylesheet" type="text/css" href="css/style.css" />
        <link rel="icon" href="images/favicon.ico" type="favicon" sizes="16x16" />
        <%@page import="log15.*" %>
        <%@page import="javax.servlet.http.Cookie" %>
        <%@page import="java.sql.*" %>
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
        <style>
            .selected{
                background-color: lightgreen;
            }
            
            .row{
                cursor: pointer;
            }
        </style>
        <script>
            /*All the objects.*/
            
            /*A simple object for a route.*/
            function Route(){
                this.start = null;
                this.destination = null;
                this.waypoints = [];
            };
            
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
        </script>
        <script>
            var MAXDURATION = 36000;
            var map = null;
            var directionsService = new google.maps.DirectionsService();
            var directionsDisplay = new google.maps.DirectionsRenderer();
            var matrixService = new google.maps.DistanceMatrixService();
            var geocoder = new google.maps.Geocoder();
            var shipment = new Route();
            var newRoute = new Route();
            var newStart, newDest;
            var placesVisited = [];
            var row, ajaxResponse;

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
            
            /*Create and display route. If handler is not undefined, recall it after the route has been created.*/
            function create_route(origin, destination, waypoints, handler, visible){
                /*Create the request for the route.*/
                var request = {
                    origin: origin,
                    destination: destination,
                    waypoints: waypoints,
                    travelMode: google.maps.DirectionsTravelMode.DRIVING
                };
                
                /*Set the map in which draw the route and what to do when it's ready.*/
                directionsService.route(request, function(response, status){
                    if (status == google.maps.DirectionsStatus.OK){
                        var info = new RouteInfo(response.routes[0]);
                        
                        /*Draw the route.*/
                        if(visible == undefined || visible == true)
                            directionsDisplay.setDirections(response);
                        
                        if(handler != undefined && handler != null)
                            handler(info);
                    }
                });
            }
            
            /*Create a new route with two new places and when the operation is done, recall handler.*/
            function create_new_route(newPlace, handler){
                newStart = newPlace[0];
                newDest = newPlace[1];
               
                /*Create an array with all the places to visit.*/
                var places = placesVisited.slice();
                places.push(newStart);
                places.push(newDest);

                /*Create the request for matrix distances service.*/
                var request = {
                    origins: places,
                    destinations: places,
                    travelMode: google.maps.TravelMode.DRIVING
                };

                matrixService.getDistanceMatrix(request, function(response, status){
                    if(status === google.maps.DistanceMatrixStatus.OK){
                        var minDist = Number.MAX_VALUE, dijk;
                        
                        /*For every start, apply Dijkstra.*/
                        for(var row = 0; row < response.rows.length; row += 2){
                            dijk = Dijkstra(response.rows, row);
                            
                            /*If the returned route is the shortest one, save it.*/
                            if(dijk.dist < minDist){
                                minDist = dijk.dist;
                                newRoute.start = response.originAddresses[dijk.start];
                                newRoute.destination = response.originAddresses[dijk.dest];
                                newRoute.waypoints = [];
                                for(var i = 0; i < dijk.waypoints.length; i++)
                                    newRoute.waypoints.push({location: response.originAddresses[dijk.waypoints[i]]});
                            } 
                        }
                        /*Recall the handler.*/
                        handler(minDist);
                    }
                    else
                        alert("Problemi con i servizi google, assicurarsi che vi sia connessione o riprovare più tardi.\n\
                                Errore: " + status);
                });
            }
            
            /*Search for the shortest path.*/
            function Dijkstra(matrix, startInd){
                var s, e, min, currDist = 0, i, j;
                var w = [], visited = [], toVisit = [];

                /*Initialize the array of visited places.*/
                for(i = 0; i < matrix.length; i++)
                    visited[i] = false;

                /*Search for the nearest place and make it the first. waypoint.*/
                toVisit.push({i: startInd, j: startInd+1});
                for(j = 0; j < matrix.length; j += 2)
                    if(j != startInd)
                        toVisit.push({i: startInd, j: j});

                min = search_min_matrix(matrix, toVisit);
                s = startInd;
                w[0] = min.j;
                visited[s] = true;
                visited[w[0]] = true;
                currDist += matrix[s].elements[w[0]].distance.value;

                /*For every waypoints, search the nearest one, and make it the next.
                 * A destination can be visited only if its start was already visited.*/
                for(i = 0; i < matrix.length - 3; i++){
                    toVisit = [];

                    for(j = 0; j < matrix.length; j++)
                        if(!visited[j] && (j%2 == 0 || visited[j - 1]))
                            toVisit.push({i: w[i], j: j});

                    min = search_min_matrix(matrix, toVisit);
                    w[i+1] = min.j;

                    visited[w[i+1]] = true;
                    currDist += matrix[w[i]].elements[w[i+1]].distance.value;
                }

                /*The destination is the place not visited yet.*/
                for(i = 0; i < matrix.length; i++)
                    if(!visited[i])
                        e = i;

                currDist += matrix[w[w.length-1]].elements[e].distance.value;
                
                /*Return the shortest path and its length.*/
                return {start: s, dest: e, waypoints: w, dist: currDist};
            }
            
            /*Search the smallest route in the matrix rows between the places.*/
            function search_min_matrix(rows, places){
                var min = Number.MAX_VALUE;
                var ret = {i: -1, j: -1};

                for(k = 0; k < places.length; k++){
                    var i = places[k].i, j = places[k].j;

                    if(rows[i].elements[j].distance.value < min){
                        min = rows[i].elements[j].distance.value;
                        ret.i = i;
                        ret.j = j;
                    }
                }
                
                return ret;
            }
            
            /*Use ajax to find a valid automatic shipment.*/
            function find_shipment(ind){
                var rows = document.getElementsByClassName("row");
                
                /*Search if the destination of the shipment and the start of the current client are the same.*/
                if(ind < 0){
                    /*Find the index of the row to analyze.*/
                    var index = -1 * (ind + 1);
                    
                    if(index < rows.length){
                        if(rows[index].children[2].innerHTML == shipment.destination){
                            /*Copy in newRoute the current shipment, modifing it with the new destination.*/
                            newRoute.start = shipment.start;
                            //newRoute.waypoints = shipment.destination.split();
                            newRoute.waypoints.push({location: shipment.destination});
                            newRoute.destination = rows[index].children[3].innerHTML;
                            
                            create_route(newRoute.start, newRoute.destination, newRoute.waypoints, function(info){
                                var newPallet = parseInt($("input[name='pallet']").val()) + 
                                                parseInt(rows[index].children[5].innerHTML);
                                
                                if(info.duration() > MAXDURATION || newPallet > 35)
                                    find_shipment(--ind);
                                else{
                                    $("input[name='id_customers']").val($("input[name='id_customers']").val() + "," +
                                                                        rows[index].children[0].children[0].value);
                                    $("input[name='dur_tim']").val(info.duration());
                                    $("input[name='pallet']").val(newPallet);
                                    $("input[name='route']").val(JSON.stringify(newRoute));
                                    $("input[name='sub']").click();
                                }
                            }, false);
                        }
                        else
                            find_shipment(--ind);
                    }
                    else
                        find_shipment(0);
                }
                /*Else search for a client that can be merged with the shipment.*/
                else if(ind < rows.length){
                    var tds = rows[ind].children;
                    
                    create_new_route([tds[2].innerHTML, tds[3].innerHTML], function(dist){
                        if(dist != undefined && dist != null){
                            var newPallet = parseInt($("input[name='pallet']").val()) + parseInt(tds[5].innerHTML);
                                        
                            if(dist > 1000000 || newPallet > 35)
                                window.setTimeout(function(){find_shipment(++ind)}, 300);
                            else{
                                shipment = newRoute;
                                create_route(shipment.start, shipment.destination, shipment.waypoints, function(info){
                                    $("input[name='id_customers']").val($("input[name='id_customers']").val() + "," +
                                                                        tds[0].children[0].value);
                                    $("input[name='dur_tim']").val(info.duration());
                                    $("input[name='pallet']").val(newPallet);
                                    $("input[name='route']").val(JSON.stringify(shipment));
                                    
                                    $("input[name='sub']").click();
                                });
                            }
                        }
                    });
                }
                else
                    $("#error_message").text("Nessun assegnamento automatico disponibile");
            }
        </script>
    </head>
    <body onload="create_map();">
         <% 
             if (request.getParameter("query") != null && request.getParameter("query").equals("fail")) 
             {
         %>
        <section class="Error">
            <article>
                <p>Errore nella creazione dell'assegnamento: nessun autista o veicolo è disponibile.</p>
            </article>
        </section>        
         <%
             } 
             if (request.getParameter("query") != null && request.getParameter("query").equals("success")) 
             {
         %>
        <section class="Success">
            <article>
                <p>L'assegnamento è stato creato con successo!</p>
            </article>
        </section>        
         <%
             }
        %>
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
            <header>ACCETTAZIONE ASSEGNAMENTI IN ATTESA</header>
            <article>
                <div id="map" style="margin: 5% 20%;width: 60%; height: 500px;"></div>
                <script>
                    <%
                        try{
                            Statement st = new DBConnector().getConnection().createStatement();
                            ResultSet rs = st.executeQuery("SELECT * FROM cliente C WHERE tipo='standard' " +
                                                            "AND DATEDIFF(C.deadline, CURDATE()) <= 7");
                            rs.next();
                    %>
                    shipment.start = "<%=rs.getString("sedePartenza")%>";
                    shipment.destination = "<%=rs.getString("sedeDestinazione")%>";
                    
                    var numGoods = parseInt(<%=rs.getString("pesoMerce")%>);
                    var newNumGoods;

                    placesVisited.push(shipment.start);
                    placesVisited.push(shipment.destination);
                    create_route(shipment.start, shipment.destination, shipment.waypoints, function(info){
                        /*Set duration visible and set shipment JSON object.*/
                        $("#customers").text("<%=rs.getString("nome")%>");
                        $("input[name='id_customers']").val("<%=rs.getString("id")%>");
                        
                        $("#dur").text(info.duration_text());
                        $("input[name='dur_time']").val(info.duration());
                        
                        $("input[name='pallet']").val(<%=rs.getString("pesoMerce")%>);
                        
                        $("input[name='route']").val(JSON.stringify(shipment));
                    });
                </script>
                <form action="ShipmentManager" method="post">
                    <table>
                        <tr>
                            <td>Clienti: </td>
                            <td id="customers"></td>
                            <td hidden><input type="text" name="id_customers"/></td>
                        </tr>
                        <tr>
                            <td>Durata: </td>
                            <td id="dur"></td>
                            <td hidden><input type="text" name="dur_time" /></td>
                        </tr>
                        <tr>
                            <td>Nuova Durata: </td>
                            <td id="new_dur"></td>
                            <td hidden><input type="text" name="new_dur_time" /></td>
                        </tr>
                        <tr>
                            <td>Numero Pallet: </td>
                            <td><input type="text" name="pallet" style="border:none" readonly/></td>
                        </tr>
                        <tr>
                            <td hidden><input type="text" name="route"/></td>
                            <td hidden><input type='text' name='deadline' value="<%=rs.getDate("deadline")%>"/></td>
                        </tr>
                        <tr>
                            <td><button type='Button' style='height: 40px; width: 180px;' class='Button' id="show_shipment">Mostra percorso attuale</button></td>
                            <td><input style='height: 40px; width: 180px;' class='Button' type="submit" name="sub" value="Crea Assegnamento"></td>
                            <td><button type='Button' style='height: 40px; width: 180px;' class='Button' onclick='find_shipment(0)' id="aut_ship">Assegnamento automatico</button></td>
                        </tr>
                    </table>
                </form>    
                <p id="error_message" style="color:red"></p>
                <%
                    String tab = "";
                    try{
                        /*If the table exists.*/
                        if(rs.next()){
                            /*Get the table meta data.*/
                            ResultSetMetaData rsmd = rs.getMetaData();
                            int count = rsmd.getColumnCount();
                            int i, idStart = 1;                            
                            
                            /* If exists id field, jump it while printing the table */
                            if (rsmd.getColumnName(1).equals("id"))
                                idStart++;
                
                            /*Start to draw the table tag.*/
                            tab = "<table id='table_customers' class='Table'>";

                            /*Draw the column's names.*/
                            tab += "<tr style='background-color: #F5F5F5;'>";
                            tab += "<td></td><td>Nome</td><td>Sede Partenza</td><td>Sede Destinazione</td><td>Deadline</td><td>Peso Merce</td><td>Tipo Spedizione</td><td></td>";
                            tab += "</tr>";

                            tab += "<tr>";
                            for (i = idStart; i<= count; i++) {
                                if (i == idStart)
                                    tab += "<td></td>";
                                else 
                                    tab += "<td><input type='text' name='" + rsmd.getColumnName(i-1) + "' /></td>";
                            }
                            tab += "<td><input type='text' id='" + rsmd.getColumnName(i-1) + "' />";
                            tab += "<td><input class='Button' style='height: 30px; width: 80px;' type='submit' name='search' value='Cerca' /></td>";
                            tab += "</tr>";
                            
                            /*Print the table.*/
                            rs.previous();
                            while(rs.next()){
                                tab += "<tr class ='row'><td>"
                                        + "<input type='hidden' name='id' value='" + rs.getString("id") + "' /></td>";
                                for(i = idStart; i <= count; i++)
                                    tab += "<td>" + rs.getString(rsmd.getColumnName(i)) + "</td>";
                                tab += "<td><button style='height: 30px; width: 80px;' class='Button' type='Button' name='test'>"
                                        + "Verifica</button></td>";
                                tab += "</tr>";
                            }

                            /*Close table tag.*/
                            tab += "</table><input class='Button' style='height: 30px; width: 100px;' type='submit' name='add' value='Aggiungi' disabled/>";
                        }
                    }
                    catch(SQLException e){%>
                        <p>Errore nella stampa della tabella</p>
                    <%}
                    
                    rs.beforeFirst();
                %>
                <%= tab %>
                <script>
                    var $thisShipment = $("#table_customers tr:nth(2)");
                    /*Modify the table.*/
                    $("#table_customers td:first-child").hide();
                    $(".row td:last-child button").attr("disabled", "true");
                    $("input[name='add']").attr("disabled", true);
                    
                    /*The selection of the row.*/
                    $(".row > :not(td:last-child)").click(function(event){
                        /*Clean the error message.*/
                        $("#error_message").text("");
                        /*Make the clicked row the selected one.*/
                        $(".selected button").attr("disabled", true);
                        $(".selected").toggleClass("selected");                  
                        $(event.target.parentNode).toggleClass("selected");
                        
                        /*Disabled add button*/
                        $("input[name='add']").attr("disabled", true);

                        /*Save the number of new goods.*/
                        td = event.target.parentNode.children;
                        newNumGoods = parseInt(td[5].innerHTML);

                        if(numGoods + newNumGoods <= 35)
                            create_new_route([td[2].innerHTML, td[3].innerHTML], 
                                            function(){$(".selected button").removeAttr("disabled");});
                        else
                            $("#error_message").text("Il peso della merce supera quello massimo");
                    });

                    /*Show the current shipment.*/
                    $("#show_shipment").click(function(){
                        create_route(shipment.start, shipment.destination, shipment.waypoints);
                    });

                    /*Show the new possible route.*/
                    $(".row button[name='test']").click(function(){
                        create_route(newRoute.start, newRoute.destination, newRoute.waypoints, function(info){
                            /*Update the new route duration.*/
                            $("#new_dur").text(info.duration_text());
                            $("input[name='new_dur_time']").val(info.duration());
                            $("input[name='add']").attr("disabled", true);
                            
                            /*If its duration is less than 10 hours, it can be added to the shipment.*/
                            if(info.duration() <= MAXDURATION)
                                $("input[name='add']").removeAttr("disabled");
                            else
                                $("#error_message").text("The route is too long");
                        });
                    });

                    /*Add the new shipment to the first one.*/
                    $("input[name='add']").click(function(){
                        /*If the shipment to add is not the selected one, delete the row and update the 
                         * shipment route. */
                        var newName = $(".selected td:nth(1)").text();
                        var newId = $(".selected input[name='id']").val();

                        $(".selected").hide("slow");
                        $(".selected").remove();
                        $(this).attr("disabled",true);

                        /*Update route.*/
                        copy_shipment(newRoute, shipment);
                        create_route(shipment.start, shipment.destination, shipment.waypoints, function(info){
                            /*Update the duration and shipment JSON object.*/
                            $("#dur").text(info.duration_text());
                            $("input[name='dur_time']").val(info.duration());
                            $("input[name='route']").val(JSON.stringify(shipment));
                        });
                        
                        /*Update the number of goods.*/
                        numGoods += newNumGoods;
                        
                        /*Update customers.*/
                        $("#customers").text($("#customers").text() + ", " + newName);
                        $("input[name='id_customers']").val($("input[name='id_customers']").val() + ", " + newId);

                        /*Update number of pallet.*/
                        $("input[name='pallet']").val(numGoods);
                        
                        /*Update visited places.*/
                        placesVisited.push(newStart);
                        placesVisited.push(newDest);
                    });
                    
                    function copy_shipment(from, to){
                        to.start = from.start;
                        to.dest = from.dest;
                        to.waypoints = from.waypoints;
                    }
                </script>
                <%}
                    catch(SQLException e){ 
                %>
                <p>Nessun assegnamento da gestire.</p>
                <%
                    }
                %>
            </article>
        </section>
    </body>
</html>