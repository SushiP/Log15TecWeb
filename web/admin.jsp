<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Admin Panel</title>
        <script src="https://maps.googleapis.com/maps/api/js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script src="manageMap.js"></script>
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
            
            #customers{
                border: none;
                cursor: default;
                font-size: 1em;
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
        </script>
        <script>
            var shipment = new Route();
            var newRoute = new Route();

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
            
            /*Use ajax to find a valid automatic shipment.*/
            function find_shipment(ind){
                var rows = document.getElementsByClassName("row");
                
                /*Search if the destination of the shipment and the start of the current client are the same.*/
                if(ind < 0){
                    /*Start the loading screen*/
                    if(ind == -1)
                        loading_screen();
                    /*Find the index of the row to analyze.*/
                    var index = -1 * (ind + 1);
                    
                    if(index < rows.length){
                        if(rows[index].children[2].innerHTML == shipment.destination){
                            /*Copy in newRoute the current shipment, modifing it with the new destination.*/
                            newRoute.start = shipment.start;
                            newRoute.waypoints = shipment.waypoints.slice();
                            newRoute.waypoints.push({location: shipment.destination});
                            newRoute.destination = rows[index].children[3].innerHTML;

                            function save_scope(ind){
                                create_route(newRoute.start, newRoute.destination, newRoute.waypoints, function(info){
                                    var newPallet = parseInt($("input[name='pallet']").val()) + 
                                                    parseInt(rows[ind].children[5].innerHTML);
                                    var newName = rows[ind].children[1].innerHTML;
                                    
                                    if(info.duration() > MAXDURATION || newPallet > 35)
                                        find_shipment(--ind);
                                    else{
                                        $("#customers").val($("#customers").val() + "," + newName);
                                        $("input[name='id_customers']").val($("input[name='id_customers']").val() + "," +
                                                                            rows[ind].children[0].children[0].value);
                                        $("input[name='dur_tim']").val(info.duration());
                                        $("input[name='pallet']").val(newPallet);
                                        $("input[name='route']").val(JSON.stringify(newRoute));
                                        $("input[name='sub']").click();
                                    }
                                }, false);
                            }
                            
                            save_scope(index);
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
                else{
                    $(".loading").remove();
                    $("#error_message").text("Nessun assegnamento automatico disponibile");
                }
            }
            
            function loading_screen(){
                var $screen = $(document.createElement("div")).addClass("loading");
                
                $("body").append($screen);
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
                <div id="map" style="width: 1024px; height: 500px;"></div>
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
                        $("input[name='id_customers']").val("<%=rs.getString("id")%>");
                        
                        /*Set the other attributes.*/
                        $("#customers").val("<%=rs.getString("nome")%>");
                        $("input[name='deadline']").val("<%=rs.getDate("deadline")%>");
                        
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
                            <td><input type="text" id="customers" name="customers"/></td>
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
                            <td hidden><input type='text' name='deadline'/></td>
                        </tr>
                        <tr>
                            <td><button type='Button' style='height: 40px; width: 180px;' class='Button' id="show_shipment">Mostra percorso attuale</button></td>
                            <td><input style='height: 40px; width: 180px;' class='Button' type="submit" name="sub" value="Crea Assegnamento"></td>
                            <td><button type='Button' style='height: 40px; width: 180px;' class='Button' onclick='find_shipment(-1)' id="aut_ship">Assegnamento automatico</button></td>
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
                        $("#error_message").empty();
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
                        $("#customers").val($("#customers").val() + ", " + newName);
                        $("input[name='id_customers']").val($("input[name='id_customers']").val() + "," + newId);

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