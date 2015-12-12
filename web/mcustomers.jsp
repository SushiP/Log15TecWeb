<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Manage Customers</title>
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
            String customers = null;
            String id = null;
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
                <p>Errore nell'inserimento: controlla che tutti i campi siano non vuoti, che la deadline abbia almeno 7 giorni di distanza da oggi ed i campi sede destinazione-arrivo divergano.</p>
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
                <p>Errore nella modifica: controlla che tutti i campi siano non vuoti, che la nuova deadline non sia più vecchia della precedente ed i campi sede destinazione-arrivo divergano.</p>
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
            INSERISCI CLIENTE
        <%
            }
            else if (request.getParameter("op") != null && request.getParameter("op").equals("update"))
            {
        %>
            MODIFICA CLIENTE
        <%
            }
            else
            {
        %>
            GESTIONE CLIENTI
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
                <form action="CustomerManager" method="post">
                    <input type="text" name="nome" placeholder="Nome cliente" 
                           value="<%if(sess.getAttribute("nome") != null) 
                                        out.println((String)sess.getAttribute("nome"));%>"/><br />
                    <input type="text" name="sedePartenza" placeholder="Sede di partenza"
                           value="<%if(sess.getAttribute("sedePartenza") != null) 
                                        out.println((String)sess.getAttribute("sedePartenza"));%>"/><br />
                    <input type="text" name="sedeDestinazione" placeholder="Sede di destinazione" 
                           value="<%if(sess.getAttribute("sedeDestinazione") != null) 
                                        out.println((String)sess.getAttribute("sedeDestinazione"));%>"/><br />
                    Deadline: <br />
                    <input type="date" name="deadline" 
                           value="<%if(sess.getAttribute("deadline") != null) 
                                        out.println((String)sess.getAttribute("deadline"));%>"/><br />
                    Peso merce: <br />
                    <%
                        Integer peso = null;
                        if(sess.getAttribute("pesoMerce") != null) 
                            peso = Integer.parseInt((String)sess.getAttribute("pesoMerce"));
                    %>
                    <select name="pesoMerce">
                        <option value="5" <%if(peso != null && peso.equals(5)) out.println("selected");%> >5</option>
                        <option value="10" <%if(peso != null && peso.equals(10)) out.println("selected");%> >10</option>
                        <option value="20" <%if(peso != null && peso.equals(20)) out.println("selected");%> >20</option>
                        <option value="35" <%if(peso != null && peso.equals(35)) out.println("selected");%> >35</option>
                    </select> <br />
                    Tipo Spedizione: <br />
                    <%
                        String tipo = null;
                        if(sess.getAttribute("tipo") != null) 
                            tipo = (String)sess.getAttribute("tipo");
                    %>
                    <select name="tipo">
                        <option value="Standard" <%if(tipo != null && tipo.equals("Standard")) out.println("selected");%> >Standard</option>
                        <option value="Veloce" <%if(tipo != null && tipo.equals("Veloce")) out.println("selected");%> >Veloce</option>
                        <option value="Fulminea" <%if(tipo != null && tipo.equals("Fulminea")) out.println("selected");%> >Fulminea</option>
                    </select><br /><br />
                    <input type="submit" value="Inserisci" name="insert" />
                    <input type="hidden" name="operation" value="insert" />
                </form>
                <a href="mcustomers.jsp"><button>Annulla</button></a>
                <%
                        }
                        else if (request.getParameter("op").equals("update"))
                        {
                            if (request.getParameter("id") != null && !request.getParameter("id").equals(""))
                            {
                                id = request.getParameter("id");
                                row = interrogator.getCustomerRow(id);
                %>
                <form action="CustomerManager" method="post">
                    <input type="hidden" name="id" value="<%=row[1]%>" />
                    <input type="text" name="nome" placeholder="Nome cliente" value="<%=row[2]%>" /><br />
                    <input type="text" name="sedePartenza" placeholder="Sede di partenza" value="<%=row[3]%>" /><br />
                    <input type="text" name="sedeDestinazione" placeholder="Sede di destinazione" value="<%=row[4]%>" /><br />
                    Deadline: <br />
                    <input type="date" name="deadline" value="<%=row[5]%>" /><br />
                    Peso merce: <br />
                    <select name="pesoMerce">
                        <option value="5" <% if (row[6].equals("5")) out.println("selected"); %>>5</option>
                        <option value="10" <% if (row[6].equals("10")) out.println("selected"); %>>10</option>
                        <option value="15" <% if (row[6].equals("20")) out.println("selected"); %>>20</option>
                        <option value="35" <% if (row[6].equals("35")) out.println("selected"); %>>35</option>
                    </select> <br />
                    Tipo Spedizione: <br />
                    <select name="tipo">
                        <option value="Standard" <% if (row[7].equals("Standard")) out.println("selected"); %>>Standard</option>
                        <option value="Veloce" <% if (row[7].equals("Veloce")) out.println("selected"); %>>Veloce</option>
                        <option value="Fulminea" <% if (row[7].equals("Fulminea")) out.println("selected"); %>>Fulminea</option>
                    </select><br /><br />
                    <input type="submit" value="Modifica" name="update" />
                    <input type="hidden" name="operation" value="update" />
                    <input type="hidden" name="odeadline" value="<%=row[5]%>" />
                </form>
                <a href="mcustomers.jsp"><button>Annulla</button></a>
                <%
                            }
                            else {
                                response.setStatus(302);
                                response.setHeader("location", "mcustomers.jsp");
                            }
                        }
                    }
                    else
                    {
                %>
                <p style="text-align: right; margin: 0;"><a href="mcustomers.jsp"><button>Refresh</button></a> <a href="mcustomers.jsp?op=insert"><button>Inserisci</button></a>
                <% customers = interrogator.getCustomersTable(); %>
                <%=customers%>
                <script>
                    /* Search function */
                    $("input[value='Cerca']").click(function(){
                        parameters = new Array(6);
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