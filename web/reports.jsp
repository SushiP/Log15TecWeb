<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="https://maps.googleapis.com/maps/api/js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <link rel="stylesheet" type="text/css" href="css/style.css" />
        <link rel="icon" href="images/favicon.ico" type="favicon" sizes="16x16" />
        <title>Log15 Driver Panel</title>
        <%@page import="log15.*" %>
        <%@page import="javax.servlet.http.Cookie" %>
        <%@page import="java.sql.*" %>
        <%!
            DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
            String userType = null, driver = null, logTime = null, dlicence = null;
        %>
        <%--Be sure the driver was successfully logged--%>
        <%
            Cookie[] cookies = request.getCookies();
            
            for(Cookie cookie : cookies)
                if(cookie.getName().equals("session")){
                    userType = interrogator.getSessionUser(cookie.getValue());
                    driver = interrogator.getDriverFromSession(cookie.getValue());
                    logTime = interrogator.getLogTimeFromSession(cookie.getValue());
                    dlicence = interrogator.getUsernameFromSession(cookie.getValue());
                }
            
            if(userType == null){
                response.setStatus(302);
                response.setHeader("location", "index.jsp");
            }
            else if (userType.equals("Admin")){
                response.setStatus(302);
                response.setHeader("location", "admin.jsp");
            }
        %>
    </head>
    <body>
        <% 
            String error = request.getParameter("error");
            if (error != null) 
            {
        %>
        <section class="Error">
            <article>
                <p>
                    <%
                        int numErr = Integer.parseInt(error);
                        if(numErr == 0)
                            out.println("Errore nella connessione al database, controllare che tutto funzioni correttamente.");
                        else if(numErr == 1)
                            out.println("Numero massimo assenze mensili raggiunte, impossibile rifiutare");
                        else if(numErr == 2)
                            out.println("Nessun altro autista disponibile, impossibile rifiutare");
                    %>
                </p>
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
                                <li><a href="reports.jsp">Reports</a></li>
                            </ul>
                        </nav>
                    </td>
                    <td style="width: 15%; text-align: right;"><p>Benvenuto <b><%=driver%></b><br /><i>Accesso effettuato alle <%=logTime%></i><br />(<a href='Logout?username=<%=driver%>'> logout </a>)</p></td>
                </tr>
            </table>
        </header>
        <section class="Container">
            <header>
                REPORTS
            </header>
            <article>
                <%--Find the current shipment for print it--%>
                <%
                    String query = "SELECT * FROM assegnamento WHERE autista = '" + dlicence + "' AND deadline = current_date()";
                    try{
                        Statement st = new DBConnector().getConnection().createStatement();
                        ResultSet rs = st.executeQuery(query);
                        if(rs.next()){
                %>
                <form id="buttons_form" action="Report">
                    <input type="text" value="<%=rs.getString("id")%>" name="id" hidden/>
                    <input type="submit" value="Partenza" name="Partenza" class="Button"/>
                    <input type="submit" value="Arrivo" name="Arrivo" class="Button"/>
                    <button type="button" id="problem_button" class="Button">Riporta un problema</button>
                </form>
                <form id="problem_form" hidden action="Report">
                    <input type="text" value="<%=rs.getString("id")%>" name="id" hidden/>
                    <table>
                        <tr>
                            <td><label>Minuti ritardo: </label></td>
                            <td><input type="number" min="0" max="300"/></td>
                        </tr>
                        <tr>
                            <td><label>Descrizione aggiuntiva</label></td>
                            <td><textarea></textarea></td>
                        </tr>
                        <tr>
                            <td><input type="submit" value="Invia report" class="Button"/></td>
                        </tr>
                    </table>
                </form>
                <script>
                    $("#problem_button").click(function(){
                        $("#problem_form").show("medium");
                        $("#buttons_form").hide("fast");
                    });
                    
                    var directionsService = new google.maps.DirectionsService();
                    /*Create a new route with two new places and when the operation is done, recall handler.*/
                    function control_duration(){
                        var route = JSON.parse('<%=rs.getString("percorso")%>');
                        
                        /*Create the request for the route.*/
                        var request = {
                            origin: route.start,
                            destination: route.destination,
                            waypoints: route.waypoints,
                            travelMode: google.maps.DirectionsTravelMode.DRIVING
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

                        /*Control if according to google the journey is finished.*/
                        directionsService.route(request, function(response, status){
                            if (status == google.maps.DirectionsStatus.OK){
                                var info = new RouteInfo(response.routes[0]);
                                /*Set the start date.*/
                                var hour = "<%=rs.getString("oraPartenza")%>".split(" ")[1].split(":");
                                var start = new Date(), currDate = new Date();
                                start.setHours(hour[0]);
                                start.setMinutes(hour[1]);
                                
                                /*If the current time is earlier than google arrive time by one hour, disable arrive button.*/
                                if(info.duration() - ((currDate - start)/1000) > 3600)
                                    $("#buttons_form > input[name='Arrivo']").attr("disabled", true);
                            }
                        });
                    }
                    <%
                        if(rs.getString("oraPartenza") == null){
                    %>
                    $("#buttons_form > input[name='Arrivo']").attr("disabled", true);
                    <%
                        }
                        else if(rs.getString("oraArrivo") == null){
                    %>
                    $("#buttons_form > input[name='Partenza']").attr("disabled", true);
                    //control_duration();  
                    <%
                        }
                    %>
                </script>
                <%        }
                    }catch(SQLException e){
                        System.out.println("Errore nella connessione al database:" + e.getMessage());
                    }
                %>
            </article>
        </section>
        
    </body>
</html>
