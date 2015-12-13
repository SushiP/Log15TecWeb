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
            
            /*The object to transform the address in LatLng objects.*/
            var coords = {
                addPlaces: function(places, i){
                    /*If is the first call of the function, analyze the first element.*/
                    if(i == undefined)
                        i = 0;

                    if(i < places.length){
                        /*Analyze the i-est place, and if it has never been converted before,
                         * add it to the list of places.*/
                        var place = places[i];
                        if(this[place] == undefined){
                            geocoder.geocode({'address': place}, function(results, status){
                                if(status == google.maps.GeocoderStatus.OK){
                                    coords[place] = results[0].geometry.location;
                                    coords.addPlaces(places, i+1);
                                }
                                else
                                    alert("Problem: " + status);
                            });
                        }
                        else
                            this.addPlaces(places, i+1);
                    }
                    else
                        create_new_route(places);
                }
            };
        </script>
        <script>
            var map = null;
            var directionsService = new google.maps.DirectionsService();
            var directionsDisplay = new google.maps.DirectionsRenderer({draggable: "true"});
            var matrixService = new google.maps.DistanceMatrixService();
            var geocoder = new google.maps.Geocoder();
            var shipment = new Route();
            var newRoute = new Route();
            var newStart, newDest;
            var placesVisited = [];

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
            
            /*Create and display route.*/
            function create_route(origin, destination, waypoints, id){
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
                        
                        /*Draw the route and its info.*/
                        directionsDisplay.setDirections(response);
                        
                        if(id != undefined && id != null){
                            $("#" + id + "_dur").text(info.duration_text());
                            $("#" + id + "_dur_time").val(info.duration());
                            /*If the shipment lasts less than 10hour, the new shipment can be added.*/
                            if(info.duration() < 36000)
                                $("input[name='del']").removeAttr("disabled");
                        }
                        else{
                            $("#dur").text(info.duration_text());
                        }
                            
                    }
                });
            }
            
            function get_coords(place, index){
                geocoder.geocode({'address': place}, function(results, status){
                    if(status == google.maps.GeocoderStatus.OK)
                        shipment[index] = results[0].geometry.location;
                    else
                        alert("Problem: " + status);
                });
            }
            
            function route_controller(){
                var id = window.setInterval(function(){
                    if(shipment.start && shipment.destination){
                        placesVisited.push(shipment.start);
                        placesVisited.push(shipment.destination);
                        create_route(shipment.start, shipment.destination, shipment.waypoints);
                        clear();
                    }
                }, 1000);

                function clear(){
                    window.clearInterval(id);
                }
            }
            
            /*Create a new route with two new places.*/
            function create_new_route(newPlace){
                newStart = newPlace[0];
                newDest = newPlace[1];
                
                /*Create an array with all the places to visit.*/
                var places = placesVisited;
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
                        var s, e, min;
                        var w = [], visited = [], toVisit = [];
                        
                        /*Initialize the array of visited places.*/
                        for(i = 0; i < response.rows.length; i++)
                            visited[i] = false;

                        /*Riempiamo un array con oggetti che rappresentano i punti della matrice da analizzare.*/
                        for(i = 0; i < response.rows.length; i += 2){
                            toVisit.push({i: i, j: i+1});
                            for(j = 0; j < response.rows.length; j += 2)
                                if(j != i)
                                    toVisit.push({i: i, j: j});
                        }
                        
                        /*Cerchiamo il minimo tra i vari posti analizzati ed avremo l'inizio del percorso ed il primo
                         * wayoint.*/
                        min = search_min_matrix(response.rows, toVisit);
                        s = min.i;
                        w[0] = min.j;
                        visited[s] = true;
                        visited[w[0]] = true;
                        
                        /*Per ogni waypoints cerchiamo quale dei luoghi della matrice è il più vicino con lo stesso
                         * metodo utilizzato prima (ATTENZIONE: un luogo dispari, ovvero una destinazione, può essere
                         * raggiunto solo se la sua partenza è stata raggiunta).*/
                        for(i = 0; i < response.rows.length - 3; i++){
                            toVisit = [];
                            
                            for(j = 0; j < response.rows.length; j++)
                                if(!visited[j] && (j%2 == 0 || visited[j - 1]))
                                    toVisit.push({i: w[i], j: j});
                            
                            min = search_min_matrix(response.rows, toVisit);
                            w[i+1] = min.j;
                            
                            visited[w[i+1]] = true;
                        }
                        
                        /*La fine è l'unico posto non ancora visitato*/
                        for(i = 0; i < response.rows.length; i++)
                            if(!visited[i])
                                e = i;
                        
                        newRoute.start = response.originAddresses[s];
                        newRoute.destination = response.originAddresses[e];
                        newRoute.waypoints = [];
                        for(i = 0; i < w.length; i++)
                            newRoute.waypoints.push({location: response.originAddresses[w[i]]});
                        
                        $(".selected button").removeAttr("disabled");
                    }
                    else
                        alert("Problemi con i servizi google, assicurarsi che vi sia connessione o riprovare più tardi.\n\
                                Errore: " + status);
                });
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
        </script>
    </head>
    <body onload="create_map();">
        <header class="Top">
            <table style="width: 100%; padding: 0px;">
                <tr>
                    <td style="width: 5%;"><a href="admin.jsp"><img src="images/logo.png" onmouseover="this.src='images/logo_on.png'" onmouseout="this.src='images/logo.png'" alt="Logo" /></a></td>
                    <td style="width: 75%;">
                        <nav>
                            <ul>
                                <li><a href="mcustomers.jsp">Gestione Clienti</a></li>
                                <li><a href="mdrivers.jsp">Gestione Autisti</a></li>
                                <li><a href="mvehicles.jsp">Gestione Veicoli</a></li>
                                <li><a href="mshipments.jsp">Gestione Spedizioni</a></li>
                            </ul>
                        </nav>
                    </td>
                    <td style="width: 15%; text-align: right;"><p>Benvenuto <b><%=username%></b><br /><i>Accesso effettuato alle <%=logTime%></i><br />(<a href='Logout?username=<%=username%>'>logout</a>)</p></td>
                </tr>
            </table>
        </header>
        <section class="Container">
            <header>ACCETTAZIONE ASSEGNAMENTI IN ATTESA</header>
            <article>
                <div id="map" style="margin: 5% 20%;width: 60%; height: 500px;"></div>
                <script>
                    <%
                        Statement st = new DBConnector().getConnection().createStatement();
                        ResultSet rs = st.executeQuery("SELECT * FROM cliente WHERE tipo='standard'");
                        rs.next();
                    %>
                    var shipment = [{nome : "<%=rs.getString("nome")%>"}];
                    get_coords("<%=rs.getString("sedePartenza")%>", "start");
                    get_coords("<%=rs.getString("sedeDestinazione")%>", "destination");
                    var numGoods = parseInt(<%=rs.getString("pesoMerce")%>);
                    var newNumGoods;

                    route_controller();
                </script>
                <form>
                    <table>
                        <tr>
                            <td>Clienti: </td>
                            <td id="customers"><%=rs.getString("nome")%></td>
                            <td hidden><input type="text" name="id_customers" /></td>
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
                            <td id="pallet"><%=rs.getString("pesoMerce")%></td>
                        </tr>
                        <tr>
                            <td><button id="show_shipment">Mostra percorso attuale</button></td>
                            <td><input type="submit" name="sub" value="Crea Assegnamento"></td>
                        </tr>
                    </table>
                </form>    
                <p id="error_message" style="color:red"></p>
                <%= interrogator.getCustomersTable()%>
                <script>
                    var $thisShipment = $("#table_customers tr:nth(2)");
                    /*Modify the table.*/
                    $thisShipment.remove();
                    $("#table_customers td:first-child").remove();
                    $("#table_customers .row td a").remove();
                    $("#table_customers .row td:last-child").html("<button disabled>Testa</button>");
                    $("input[name='del']").val("Aggiungi").attr("disabled", true);

                    /*The selection of the row.*/
                    $(".row > :not(td:last-child)").click(function(event){
                        /*Clean the error message.*/
                        $("#error_message").text("");
                        /*Make the clicked row the selected one.*/
                        $(".selected button").attr("disabled", true);
                        $(".selected").toggleClass("selected");                  
                        $(event.target.parentNode).toggleClass("selected");
                        $("input[name='del']").attr("disabled", true);

                        /*Recall the function for get the coords.*/
                        td = event.target.parentNode.children;
                        newNumGoods = parseInt(td[4].innerHTML);

                        if(numGoods + newNumGoods <= 35)
                            coords.addPlaces([td[1].innerHTML, td[2].innerHTML]);
                        else
                            $("#error_message").text("Il peso della merce supera quello massimo");
                    });

                    /*Show the new possible route.*/
                    $("#show_shipment").click(function(){
                        create_route(shipment.start, shipment.destination, shipment.waypoints, null);
                    });

                    /*Show the new possible route.*/
                    $(".row button").click(function(){
                        create_route(newRoute.start, newRoute.destination, newRoute.waypoints, "new");
                    });

                    /*Add the new shipment to the first one.*/
                    $("input[name='del']").click(function(){
                        /*If the shipment to add is not the selected one, delete the row and update the 
                         * shipment route. */
                        var newName = $(".selected td:first-child").text();
                        $(".selected").hide("slow");
                        $(".selected").remove();
                        $(this).attr("disabled",true);

                        /*Update route.*/
                        shipment = newRoute;
                        create_route(shipment.start, shipment.destination, shipment.waypoints, null);

                        /*Update duration.*/
                        $("#dur_time").val() = $("new_dur_time").val();

                        /*Update customers.*/
                        $("#customers").text($("#customers").text() + ", " + newName);

                        /*Update number of pallet.*/
                        numGoods += newNumGoods;
                        $("#pallet").text(numGoods);

                        /*Update visited places.*/
                        placesVisited.push(newStart);
                        placesVisited.push(newDest);
                    });         
                </script>
            </article>
        </section>
    </body>
</html>