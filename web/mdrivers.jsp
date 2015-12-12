<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Manage Drivers</title>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
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
        <section class="Container">
            <header>
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
                <%
                    if (request.getParameter("op") != null) 
                    {
                        if (request.getParameter("op").equals("insert"))
                        {
                            HttpSession sess = request.getSession();
                %>
                <form action="DriversManager" method="post">
                    <input type="text" name="patente" placeholder="Patente autista" 
                           value="<%if(sess.getAttribute("patente") != null) 
                                        out.println((String)sess.getAttribute("patente"));%>"/><br />
                    <input type="text" name="nome" placeholder="Nome autista"
                           value="<%if(sess.getAttribute("nome") != null) 
                                        out.println((String)sess.getAttribute("nome"));%>"/><br />
                    <input type="text" name="cognome" placeholder="Cognome autista" 
                           value="<%if(sess.getAttribute("cognome") != null) 
                                        out.println((String)sess.getAttribute("cognome"));%>"/><br />
                    Assenze mensili: <br />
                    <input type="text" name="assenzeMensili" readonly="true" 
                           value="<%if(sess.getAttribute("assenzeMensili") != null) 
                                        out.println((String)sess.getAttribute("assenzeMensili")); else out.println('0');%>"/><br /><br />
                    <input type="submit" value="Inserisci" name="insert" />
                    <input type="hidden" name="operation" value="insert" />
                </form>
                <a href="mdrivers.jsp"><button>Annulla</button></a>
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
                    <input type="text" readonly="readonly" name="patente" placeholder="Patente autista" value="<%=row[1]%>" /><br />
                    <input type="text" name="nome" placeholder="Nome autista" value="<%=row[2]%>" /><br />
                    <input type="text" name="cognome" placeholder="Cognome autista" value="<%=row[3]%>" /><br />
                    Assenze mensili: <br />
                    <input type="text" name="assenzeMensili" value="<%=row[4]%>" readonly="true" /><br /><br />
                    <input type="submit" value="Modifica" name="update" />
                    <input type="hidden" name="operation" value="update" />
                </form>
                <a href="mdrivers.jsp"><button>Annulla</button></a>
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
                <p style="text-align: right; margin: 0;"><a href="mdrivers.jsp"><button>Refresh</button></a> <a href="mdrivers.jsp?op=insert"><button>Inserisci</button></a>
                <% drivers = interrogator.getDriversTable(); %>
                <%=drivers%>
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
                    }
                %>
            </article>
        </section>
    </body>
</html>
