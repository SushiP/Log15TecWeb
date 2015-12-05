<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="it">
    <head>
        <meta charset="UTF-8" />
        <title>Log15 Staff Login</title>
        <link rel="stylesheet" type="text/css" href="css/style.css" />
        <link rel="icon" href="images/favicon.ico" type="favicon" sizes="16x16" />
    </head>
    <header>
        <a href="#"><img src="images/logo.png" onmouseover="this.src='images/logo_on.png'" onmouseout="this.src='images/logo.png'" alt="Logo" /></a>
    </header>
    <body>
        <% 
            if(request.getParameter("error")!= null){
        %>
        <p>errore</p>
        <%}%>
        <section id="Login">
            <header>Login</header>
            <article>
                <form action="Login" method="post">
                    <input type="text" placeholder="Username" name="username" /><br />
                    <input type="password" placeholder="Password" name="password" /><br />
                    <input type="submit" name="invia" value="Accedi" />
                </form>
            </article>
        </section>
    </body>
</html>
