<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="it">
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Staff Login</title>
        <link rel="stylesheet" type="text/css" href="css/style.css" />
        <link rel="icon" href="images/favicon.ico" type="favicon" sizes="16x16" />
        <%@page import="log15.*" %>
        <%@page import="javax.servlet.http.Cookie" %>
        <%!
            DBInterrogator interrogator = new DBInterrogator(new DBConnector().getConnection());
            String userType = null;
        %>
        
        <%
            Cookie[] cookies = request.getCookies();
            
            for(Cookie cookie : cookies)
                if(cookie.getName().equals("session"))
                    userType = interrogator.getSessionUser(cookie.getValue());
            
            if(userType != null){
                if(userType.equals("Admin")){
                    response.setStatus(302);
                    response.setHeader("location", "admin.jsp");
                }
                else{
                    response.setStatus(302);
                    response.setHeader("location", "driver.jsp");
                }
            }
        %>
    </head>
    <body>
        <% 
            if(request.getParameter("error")!= null)
            {
        %>
        <section class="Error">
            <article>
                <p>Errore nel recupero delle informazioni: username o password errati.</p>
            </article>
        </section>
        <%
            }       
        %>
        <header class="Top">
            <a href="#"><img src="images/logo.png" onmouseover="this.src='images/logo_on.png'" onmouseout="this.src='images/logo.png'" alt="Logo" /></a>
        </header>
        <section id="Login" class="Container">
            <header>LOGIN</header>
            <article>
                <form action="Login" method="post">
                    <input type="text" placeholder="Username" name="username" class="Input" style="width: 340px;"/><br />
                    <input type="password" placeholder="Password" name="password" class="Input" style="width: 340px; margin-top: 15px;" /><br />
                    <input type="submit" name="invia" value="Accedi" class="Button" style="width: 175px; height: 35px; margin-top: 15px;" />
                </form>
            </article>
        </section>
        <% if (request.getParameter("error") != null) 
            {
        %>
        <script type="text/javascript">
            document.getElementsByName("username")[0].value = "<%=request.getParameter("username")%>";
        </script>
        <%
            }
        %>
    </body>
</html>
