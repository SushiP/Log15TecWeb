<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Manage Drivers</title>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script src="controlInput.js"></script>
        <script src="search.js"></script>
        <link rel="stylesheet" type="text/css" href="css/style.css" />
        <link rel="icon" href="images/favicon.ico" type="favicon" sizes="16x16" />
        <%@page import="log15.*" %>
        <%@page import="javax.servlet.http.Cookie" %>
        <%!
            DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
            String userType = null;
            String username = null;
            String logTime = null;
            String drivers = null;
            String patente = null;
            String row[] = null;
            String search = null;
        %>
        <%--Check if driver is correctly logged in.--%>
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
                <p>Errore nell'inserimento: controlla che tutti i campi non siano vuoti ed il campo patente abbia lunghezza 10.</p>
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
                <p>Errore nella modifica: controlla che tutti i campi non siano vuoti.</p>
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
        <%--Print the right text basis on the operation.--%>
        <%
            if (request.getParameter("op") != null && request.getParameter("op").equals("insert"))
            {
        %>
            INSERISCI AUTISTA
        <%
            }
            else if (request.getParameter("op") != null && request.getParameter("op").equals("update"))
            {
        %>
            MODIFICA AUTISTA
        <%
            }
            else
            {
        %>
            GESTIONE AUTISTI
        <%
            }
        %>
            </header>
            <article>
                <%--Show the right form.--%>
                <%
                    if (request.getParameter("op") != null) 
                    {
                        if (request.getParameter("op").equals("insert"))
                        {
                            HttpSession sess = request.getSession();
                %>
                <form action="DriversManager" method="post">
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="patente" placeholder="Patente autista" 
                           value="<%if(sess.getAttribute("patente") != null) 
                                        out.println((String)sess.getAttribute("patente"));%>" required/><br />
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="nome" placeholder="Nome autista"
                           value="<%if(sess.getAttribute("nome") != null) 
                                        out.println((String)sess.getAttribute("nome"));%>"required/><br />
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="cognome" placeholder="Cognome autista" 
                           value="<%if(sess.getAttribute("cognome") != null) 
                                        out.println((String)sess.getAttribute("cognome"));%>"required/><br />
                    Assenze mensili: <br />
                    <input class="Input" type="text" name="assenzeMensili" readonly="true" 
                           value="<%if(sess.getAttribute("assenzeMensili") != null) 
                                        out.println((String)sess.getAttribute("assenzeMensili")); else out.println('0');%>"required/><br /><br />
                    <p id="error_input_message" style="color:red"></p>
                    <input style="height:30px; width:120px;" class="Button" type="submit" value="Inserisci" name="insert" required/> <a href="mdrivers.jsp"><button style="height:30px; width:120px;" class="Button" type="button">Annulla</button></a>
                    <input type="hidden" name="operation" value="insert" required/>
                </form>
                <script>
                    control_customers_input();
                </script>
                <%
                        }
                        else if (request.getParameter("op").equals("update"))
                        {
                            if (request.getParameter("patente") != null && !request.getParameter("patente").equals(""))
                            {
                                patente = request.getParameter("patente");
                                row = interrogator.getDriverRow(patente);
                %>
                <form action="DriversManager" method="post">
                    <input style="margin-bottom: 15px;" class="Input" type="text" readonly="readonly" name="patente" placeholder="Patente autista" value="<%=row[1]%>" required/><br />
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="nome" placeholder="Nome autista" value="<%=row[2]%>" required/><br />
                    <input style="margin-bottom: 15px;" class="Input" type="text" name="cognome" placeholder="Cognome autista" value="<%=row[3]%>" required/><br />
                    Assenze mensili: <br />
                    <input class="Input" type="text" name="assenzeMensili" value="<%=row[4]%>" readonly="true" required/><br /><br />
                    <p id="error_input_message" style="color:red"></p>
                    <input style="height:30px; width:120px;" class="Button" type="submit" value="Modifica" name="update" required/> <a href="mdrivers.jsp"><button style="height:30px; width:120px;" class="Button" type="button">Annulla</button></a>
                    <input type="hidden" name="operation" value="update" required/>
                </form>
                <script>
                    control_customers_input();
                </script>
                <%
                            }
                            else {
                                response.setStatus(302);
                                response.setHeader("location", "mdrivers.jsp");
                            }
                        }
                    }
                    else
                    {
                %>
                <p style="text-align: right; margin: 0;"><a href="mdrivers.jsp"><button class="Button" style="width: 100px; height: 30px;">Refresh</button></a> <a href="mdrivers.jsp?op=insert"><button class="Button" style="width: 100px; height: 30px;">Inserisci</button></a>
                <% drivers = interrogator.getDriversTable(); %>
                <%=drivers%>
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
