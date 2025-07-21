<%@ page import="java.sql.*,java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head><title>Manage Customer Representatives</title></head>
<body>
<h2>Manage Customer Representatives</h2>

<!-- Add/Edit Rep -->
<form method="post">
    <input type="hidden" name="action" value="saveRep" />
    ID: <input type="text" name="id"><br/>
    Name: <input type="text" name="name"><br/>
    Email: <input type="text" name="email"><br/>
    Phone: <input type="text" name="phone"><br/>
    <input type="submit" value="Add/Update Rep">
</form>

<!-- Delete Rep -->
<form method="post">
    <input type="hidden" name="action" value="deleteRep" />
    ID: <input type="text" name="id">
    <input type="submit" value="Delete Rep">
</form>

<%
    String action = request.getParameter("action");
    ApplicationDB db = new ApplicationDB();
    if ("saveRep".equals(action)) {
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        db.saveRep(id, name, email, phone);
        out.println("<p>Representative added/updated successfully!</p>");
    }
    if ("deleteRep".equals(action)) {
        String id = request.getParameter("id");
        db.deleteRep(id);
        out.println("<p>Representative deleted successfully!</p>");
    }
%>
<a href="adminDashboard.jsp">Dashboard</a>
</body>
</html>
