<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Manage Vehicles</title>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script src="search.js"></script>
        <script src="controlInput.js"></script>
        <link rel="stylesheet" type="text/css" href="css/style.css" />
        <link rel="icon" href="images/favicon.ico" type="favicon" sizes="16x16" />
        <%@page import="log15.*" %>
        <%@page import="javax.servlet.http.Cookie" %>
        <%!
            DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
            String userType = null;
            String username = null;
            String logTime = null;
            String vehicles = null;
            String targa = null;
            String row[] = null;
            String search = null;
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
    </head>
    <body>
         <% 
             if (request.getParameter("query") != null && request.getParameter("op") == null && !request.getParameter("query").equals("success")) 
             {
         %>
        <section class="Error">
            <article>
                <p>Errore nella cancellazione: controlla di aver selezionato almeno un campo.</p>
            </article>
        </section>        
         <%
             }
            if(request.getParameter("query") != null && request.getParameter("op") != null)
            {
                if (request.getParameter("query").equals("fail") && request.getParameter("op").equals("insert"))
                {
        %>
        <section class="Error">
            <article>
                <p>Errore nell'inserimento: controlla che tutti i campi non siano vuoti, che il campo targa abbia lunghezza 7 e l'anno di registrazione sia compreso tra il 1990 e l'anno attuale.</p>
            </article>
        </section>
        <%      }
            }
            if(request.getParameter("query") != null && request.getParameter("op") != null)
            {
                if (request.getParameter("query").equals("fail") && request.getParameter("op").equals("update"))
                {
        %>
        <section class="Error">
            <article>
                <p>Errore nella modifica: controlla che tutti i campi non siano vuoti e che l'anno di registrazione sia compreso tra il 1990 e l'anno attuale.</p>
            </article>
        </section>
        <%
                }
            }
            if (request.getParameter("query") != null && request.getParameter("query").equals("success")) 
            {
        %>
        <section class="Success">
            <article>
                <p>L'operazione è avvenuta con successo.</p>
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
            <header>
        <%
            if (request.getParameter("op") != null && request.getParameter("op").equals("insert"))
            {
        %>
            INSERISCI VEICOLO
        <%
            }
            else if (request.getParameter("op") != null && request.getParameter("op").equals("update"))
            {
        %>
            MODIFICA VEICOLO
        <%
            }
            else
            {
        %>
            GESTIONE VEICOLI
        <%
            }
        %>
            </header>
            <article>
                <%
                    if (request.getParameter("op") != null) 
                    {
                        if (request.getParameter("op").equals("insert"))
                        {
                            HttpSession sess = request.getSession();
                %>
                <form action="VehicleManager" method="post">
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="targa" placeholder="Targa veicolo" 
                           value="<%if(sess.getAttribute("targa") != null) 
                                        out.println((String)sess.getAttribute("targa"));%>" required/><br />
                    <input style="margin-bottom: 15px;" class="Input"type="text" name="annoRegistrazione" placeholder="Anno registrazione veicolo"
                           value="<%if(sess.getAttribute("annoRegistrazione") != null) 
                                        out.println((String)sess.getAttribute("annoRegistrazione"));%>" required/><br />
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="marca" placeholder="Marca veicolo"
                           value="<%if(sess.getAttribute("marca") != null) 
                                        out.println((String)sess.getAttribute("marca"));%>" required/><br />
                    Tipo Carburante:<br />
                    <%
                        String carburante = null;
                        if(sess.getAttribute("carburante") != null) 
                            carburante = (String)sess.getAttribute("carburante");
                    %>
                    <select style="margin-bottom: 15px;" class="Input" name="carburante" required>
                        <option value="Benzina" <%if(carburante != null && carburante.equals("Benzina")) out.println("selected");%> >Benzina</option>
                        <option value="Diesel" <%if(carburante != null && carburante.equals("Diesel")) out.println("selected");%> >Diesel</option>
                    </select><br />
                    Capacità: <br />
                    <%
                        Integer capacita = null;
                        if(sess.getAttribute("capacita") != null) 
                            capacita = Integer.parseInt((String)sess.getAttribute("capacita"));
                    %>
                    <select class="Input" name="capacita" required>
                        <option value="5" <%if(capacita != null && capacita.equals(5)) out.println("selected");%> >5</option>
                        <option value="10" <%if(capacita != null && capacita.equals(10)) out.println("selected");%> >10</option>
                        <option value="20" <%if(capacita != null && capacita.equals(20)) out.println("selected");%> >20</option>
                        <option value="35" <%if(capacita != null && capacita.equals(35)) out.println("selected");%> >35</option>
                    </select> <br />
                    <p id="error_input_message" style="color:red"></p>
                    <input style="height: 30px; width: 120px;" class="Button" type="submit" value="Inserisci" name="insert" /> <a href="mvehicles.jsp"><button style="height: 30px; width: 120px;" class="Button" type="button">Annulla</button></a>
                    <input type="hidden" name="operation" value="insert" />
                </form>
                <script>
                    control_vehicles_input();
                </script>
                <%
                        }
                        else if (request.getParameter("op").equals("update"))
                        {
                            if (request.getParameter("targa") != null && !request.getParameter("targa").equals(""))
                            {
                                targa = request.getParameter("targa");
                                row = interrogator.getVehicleRow(targa);
                %>
                <form action="VehicleManager" method="post">
                    <input style="margin-bottom: 15px;" class="Input" type="text" readonly="readonly" name="targa" placeholder="Targa veicolo" value="<%=row[1]%>" required/><br />
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="annoRegistrazione" placeholder="Anno registrazione veicolo" value="<%=row[2]%>" required/><br />
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="marca" placeholder="Marca veicolo" value="<%=row[4]%>" required/><br />
                    Tipo carburante: <br />
                    <select style="margin-bottom: 15px;" class="Input" name="carburante" required>
                        <option value="Benzina" <% if (row[3].equals("Benzina")) out.println("selected"); %>>Benzina</option>
                        <option value="Diesel" <% if (row[3].equals("Diesel")) out.println("selected"); %>>Diesel</option>
                    </select><br />
                    Capacità: <br />
                    <select class="Input" name="capacita" required>
                        <option value="5" <% if (row[5].equals("5")) out.println("selected"); %>>5</option>
                        <option value="10" <% if (row[5].equals("10")) out.println("selected"); %>>10</option>
                        <option value="15" <% if (row[5].equals("20")) out.println("selected"); %>>20</option>
                        <option value="35" <% if (row[5].equals("35")) out.println("selected"); %>>35</option>
                    </select><br /><br/>
                    <p id="error_input_message" style="color:red"></p>
                    <input style="height: 30px; width: 120px;" class="Button" type="submit" value="Modifica" name="update" /> <a href="mvehicles.jsp"><button style="height: 30px; width: 120px;" class="Button" type="button">Annulla</button></a>
                    <input type="hidden" name="operation" value="update" />
                </form>
                <script>
                    control_vehicles_input();
                </script>
                <%
                            }
                            else {
                                response.setStatus(302);
                                response.setHeader("location", "mvehicles.jsp");
                            }
                        }
                    }
                    else
                    {
                %>
                <p style="text-align: right; margin: 0;"><a href="mvehicles.jsp"><button class="Button" style="width: 100px; height: 30px;">Refresh</button></a> <a href="mvehicles.jsp?op=insert"><button class="Button" style="width: 100px; height: 30px;">Inserisci</button></a>
                <% vehicles = interrogator.getVehicleTable(); %>
                <%=vehicles%>
                <script>
                    /* Search function */
                    $("input[value='Cerca']").click(function(){
                        search("#search_row input[type='text']", "row")
                    });
                </script>
                <%
                    }
                %>
            </article>
        </section>
    </body>
</html>
