<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script src="https://maps.googleapis.com/maps/api/js"></script>
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
                        </nav>
                    </td>
                    <td style="width: 15%; text-align: right;"><p>Benvenuto <b><%=driver%></b><br /><i>Accesso effettuato alle <%=logTime%></i><br />(<a href='Logout?username=<%=dlicence%>'> logout </a>)</p></td>
                </tr>
            </table>
        </header>
        <section class="Container">
            <header>
                ACCETTAZIONE ASSEGNAMENTI
            </header>
            <article>
                <%--Query to recover all the shipments of the logged sriver --%>
                <%
                    String query = "SELECT * FROM assegnamento WHERE autista = \"" + dlicence + "\" AND DATEDIFF(deadline, CURDATE()) <= 7 "
                            + "AND accettato = 0";
                    ResultSet rs = null;
                    try{
                        Statement st = new DBConnector().getConnection().createStatement();
                        rs = st.executeQuery(query);  
                    }catch(SQLException e){
                        System.out.println("Errore recupero dati"); 
                %>
                        <p>Impossibile accedere al database.</p>
                <%
                    }

                    if(rs != null){
                %>
                    <table class="Table">
                        <thead>
                            <tr>
                                <th>Deadline</th>
                                <th>Partenza</th>
                                <th>Tappe intermedie</th>
                                <th>Arrivo</th>
                                <th></th><th></th>
                            </tr>
                        </thead>
                        <tbody>
                <%
                        while(rs.next()){
                %>
                            <tr id = "<%=rs.getString("id")%>">
                                <td><%=rs.getString("deadline")%></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td hidden><%=rs.getString("id")%></td>
                                <td hidden><%=rs.getString("deadline")%></td>
                                <td><button class="Button">Accetta</button></td>
                                <td><button class="Button">Rifiuta</button></td>
                                <script>
                                    /*Fill the row with data about the shipment.*/
                                    $start = $("#<%=rs.getString("id")%> td:nth(1)");
                                    $wayp = $("#<%=rs.getString("id")%> td:nth(2)");
                                    $dest = $("#<%=rs.getString("id")%> td:nth(3)");

                                    /*Parse the route and insert it into the row.*/
                                    route = JSON.parse('<%=rs.getString("percorso")%>');
                                    $start.text(route.start);
                                    $dest.text(route.destination);

                                    for(i = 0; i < route.waypoints.length; i++){
                                        $way.text($way.text() + route.waypoints[i]);
                                        if(i < route.waypoints.length - 1)
                                            $way.text($way.text() + ", ");
                                    }
                                </script>
                            </tr>
                <%
                        }
                %>
                        </tbody>
                    </table>
                    <form method="post" action="ShipmentAcceptance" hidden>
                        <input type="text" name="shipment" />
                        <input type="text" name="action" />
                        <input type="date" name="deadline" />
                        <input type="submit" />
                        <script>
                            /*When a button is pressed, recover the data about the shipment and insert them into the form.*/
                            $("table button").click(function(){
                               var shipment = this.parentNode.parentNode.children[4].innerHTML;
                               var deadline = this.parentNode.parentNode.children[5].innerHTML;

                               $("input[name='shipment']").val(shipment);
                               $("input[name='deadline']").val(deadline);
                               $("input[name='action']").val(this.innerHTML);

                               $("input[type='submit']").click();
                            });
                        </script>
                    </form>
                <%
                    }
                %> 
            </article>
        </section>
        
    </body>
</html>
