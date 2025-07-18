<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>Search Train Schedules</title></head>
<body>
<h2>Search Train Schedules</h2>

<form method="post" action="searchResults.jsp">
    Origin: <input type="text" name="origin"><br/>
    Destination: <input type="text" name="destination"><br/>
    Date (YYYY-MM-DD): <input type="text" name="date"><br/>
    <input type="submit" value="Search">
</form>

<a href="logout.jsp">Logout</a>
</body>
</html>
