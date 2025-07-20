<%@ page import="java.sql.*,java.util.*" %>
<html>
<head><title>Admin Dashboard</title></head>
<body>
<h2>Manage Customer Representatives</h2>

<!-- Add/Edit Rep -->
<form method="post" action="../AdminServlet">
    <input type="hidden" name="action" value="saveRep" />
    ID: <input type="text" name="id"><br/>
    Name: <input type="text" name="name"><br/>
    Email: <input type="text" name="email"><br/>
    Phone: <input type="text" name="phone"><br/>
    <input type="submit" value="Add/Update Rep">
</form>

<!-- Delete Rep -->
<form method="post" action="../AdminServlet">
    <input type="hidden" name="action" value="deleteRep" />
    ID: <input type="text" name="id">
    <input type="submit" value="Delete Rep">
</form>

<!--   href="loginProcess.jsp">
  <button>Back</button>
</a> -->

<h2>Monthly Sales Report</h2>
<form method="post" action="../AdminServlet">
	<input type="hidden" name="action" value="montlyReport" />
	<input type="submit" value="Generate Report">
</form>

<%
	//Display results if available
	List<String[]> report = (List<String[]>) request.getAttribute("monthlyReport");
	if (report != null){
	%>
	<table border="1">
		<tr><th>Year</th><th>Month</th><th>Total Revenue</th></tr>
		<% for (String[] row : report) { %>
			<tr>
				<td><%= row[0] %></td>
				<td><%= row[1] %></td>
				<td><%= row[2] %></td>
			</tr>
		<% } %>
	</table>
<% } %>

<h2>Revenue by Transit Line or Customer</h2>

<form method="post" action="../AdminServlet">
    <input type="hidden" name="action" value="revenueLookup" />
    
    Transit Line ID: <input type="text" name="transitLineId"><br/>
    OR<br/>
    Customer ID: <input type="text" name="customerId"><br/><br/>
    
    <input type="submit" value="Get Revenue">
</form>

<%
    String revenueResult = (String) request.getAttribute("revenueResult");
    if (revenueResult != null) {
%>
    <p><strong>Total Revenue:</strong> $<%= revenueResult %></p>
<% } %>

<h2>Top 5 Revenue-Generating Customers</h2>

<form method="post" action="../AdminServlet">
    <input type="hidden" name="action" value="topCustomers" />
    <input type="submit" value="Find Top 5 Customers">
</form>

<%
    List<String[]> topCustomers = (List<String[]>) request.getAttribute("topCustomers");
    if (topCustomers != null) {
%>
    <table border="1">
        <tr>
            <th>Rank</th>
            <th>Customer ID</th>
            <th>Name</th>
            <th>Total Revenue</th>
        </tr>
        <%
            int rank = 1;
            for (String[] customer : topCustomers) {
        %>
            <tr>
                <td><%= rank++ %></td>
                <td><%= customer[0] %></td>
                <td><%= customer[1] %></td>
                <td>$<%= customer[2] %></td>
            </tr>
        <%
            }
        %>
    </table>
<% } %>

<h2>Top 5 Most Active Transit Lines (Per Month)</h2>

<form method="post" action="../AdminServlet">
    <input type="hidden" name="action" value="topTransitLines" />
    <input type="submit" value="Find Top 5 Transit Lines">
</form>

<%
    List<String[]> topTransitLines = (List<String[]>) request.getAttribute("topTransitLines");
    if (topTransitLines != null) {
%>
    <table border="1">
        <tr>
            <th>Year</th>
            <th>Month</th>
            <th>Transit Line ID</th>
            <th>Reservations</th>
        </tr>
        <%
            for (String[] row : topTransitLines) {
        %>
            <tr>
                <td><%= row[0] %></td>
                <td><%= row[1] %></td>
                <td><%= row[2] %></td>
                <td><%= row[3] %></td>
            </tr>
        <%
            }
        %>
    </table>
<% } %>


<h2>List Reservations by Transit Line or Customer Name</h2>
<form method="post" action="../AdminServlet">
    <input type="hidden" name="action" value="listReservations" />
    Transit Line ID: <input type="text" name="transitLineId"><br/>
    OR<br/>
    Customer Name: <input type="text" name="customerName"><br/><br/>
    <input type="submit" value="List Reservations">

</form>
<%
  List<String[]> reservations = (List<String[]>)request.getAttribute("reservationsList");
  if (reservations != null) {
%>
  <table border="1">
    <tr>
      <th>Resv ID</th>
      <th>Username</th>
      <th>First Name</th>
      <th>Last Name</th>
      <th>Transit Line</th>
      <th>Reservation Time</th>
    </tr>
    <% for (String[] r : reservations) { %>
      <tr>
        <td><%= r[0] %></td>
        <td><%= r[1] %></td>
        <td><%= r[2] %></td>
        <td><%= r[3] %></td>
        <td><%= r[4] %></td>
        <td><%= r[5] %></td>
      </tr>
    <% } %>
  </table>
<% } %>


<form action="../logout.jsp" method="get">
    <input type="submit" value="Logout" />
</form>

</body>
</html>
