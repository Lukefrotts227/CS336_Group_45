<%@ page import="java.sql.*,java.util.*" %>
<html>
<head><title>Admin Dashboard</title></head>
<body>
<h2>Manage Customer Representatives</h2>

<!-- Add/Edit Rep -->
<form method="post" action="AdminServlet">
    <input type="hidden" name="action" value="saveRep" />
    ID: <input type="text" name="id"><br/>
    Name: <input type="text" name="name"><br/>
    Email: <input type="text" name="email"><br/>
    Phone: <input type="text" name="phone"><br/>
    <input type="submit" value="Add/Update Rep">
</form>

<!-- Delete Rep -->
<form method="post" action="AdminServlet">
    <input type="hidden" name="action" value="deleteRep" />
    ID: <input type="text" name="id">
    <input type="submit" value="Delete Rep">
</form>

<a href="loginProcess.jsp">
  <button>Back</button>
</a>

</body>
</html>
