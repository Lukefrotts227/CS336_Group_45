<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>Register</title></head>
<body>
    <h2>Register</h2>
    <form method="post" action="registerProcess.jsp">
        Username: <input type="text" name="username" /><br/>
        Password: <input type="password" name="password" /><br/>
        Confirm Password: <input type="password" name="confirm_password" /><br/>
        <input type="submit" value="Register" />
    </form>
    
</body>
</html>