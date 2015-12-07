<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Manage Customers</title>
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
        <header>
            <table style="width: 100%; padding: 0px;">
                <tr>
                    <td style="width: 5%;"><a href="admin.jsp"><img src="images/logo.png" onmouseover="this.src='images/logo_on.png'" onmouseout="this.src='images/logo.png'" alt="Logo" /></a></td>
                    <td style="width: 75%;">
                        <nav>
                            <ul>
                                <li><a href="mcustomers.jsp">Gestione Clienti</a></li>
                                <li><a href="mdrivers.jsp">Gestione Autisti</a></li>
                                <li><a href="mvehicles.jsp">Gestione Veicoli</a></li>
                                <li><a href="mshipemnts.jsp">Gestione Spedizioni</a></li>
                            </ul>
                        </nav>
                    </td>
                    <td style="width: 15%; text-align: right;"><p>Benvenuto <b><%=username%></b><br /><i>Accesso effettuato alle <%=logTime%></i><br />(<a href='Logout?username=<%=username%>'>logout</a>)</p></td>
                </tr>
            </table>
        </header>
         <% 
            if(request.getParameter("query")!= null)
            {
                if (request.getParameter("query").equals("fail"))
                {
        %>
        <section class="Error">
            <article>
                <p>Errore nell'inserimento della query: controlla che tutti i campi siano non vuoti e la deadline abbia almeno 7 giorni di distanza.</p>
            </article>
        </section>
        <%
                }
                if (request.getParameter("query").equals("success")) 
                {
        %>
        <section class="Success">
            <article>
                <p>L'operazione è avvenuta con successo.</p>
            </article>
        </section>
        <%
                }
            }
        %>
        <section class="Container">
            <header>Gestione Clienti</header>
            <article>
                <% if (request.getParameter("op") != null) 
                {
                    if (request.getParameter("op").equals("insert"))
                    {
                %>
                <form action="CustomerManager" method="post">
                    <input type="text" name="nome" placeholder="Nome cliente" /><br />
                    <input type="text" name="sedePartenza" placeholder="Sede di partenza" /><br />
                    <input type="text" name="sedeDestinazione" placeholder="Sede di destinazione" /><br />
                    Deadline: <br />
                    <input type="date" name="deadline" /><br />
                    Peso merce: <br />
                    <select name="pesoMerce">
                        <option value="5">5</option>
                        <option value="10">10</option>
                        <option value="15">20</option>
                        <option value="35">35</option>
                    </select> <br />
                    Tipo Spedizione: <br />
                    <select name="tipo">
                        <option value="Standard">Standard</option>
                        <option value="Veloce">Veloce</option>
                        <option value="Fulminea">Fulminea</option>
                    </select><br /><br />
                    <input type="submit" value="Inserisci" name="insert" />
                    <input type="hidden" name="operation" value="insert" />
                </form>
                <a href="mcustomers.jsp"><button>Annulla</button></a>
                <%
                    }
                    if (request.getParameter("op").equals("update"))
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
                    <input type="submit" value="Modifica" name="insert" />
                    <input type="hidden" name="operation" value="update" />
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
                <p style="text-align: right; margin: 0;"><a href="mcustomers.jsp"><button>Refresh</button></a> <button>Cancella</button> <a href="mcustomers.jsp?op=insert"><button>Inserisci</button></a></p>
                <% customers = interrogator.getTable("cliente"); %>
                <%=customers%>
                <%
                }
                %>
            </article>
        </section>
    </body>
</html>