<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml"
<head>
<title>
Staff List
</title>
</head>
<body>
<a href="index.html">Home</a>
	<br/><br/>
 
<?php $db = mysql_connect("pluto", "cg16", "DBstudent15") or die("The site database appears to be down.");
mysql_select_db("cg16db");

	
$uID = $_POST['id'];
$uage = $_POST['age'];
$uemail = $_POST['email'];

	$query= "UPDATE users SET age= '$uage', email= '$uemail' WHERE id= '$uID';";
	mysql_query($query); 
  
			
$result = mysql_query("SELECT * FROM users");
		
echo "<h1> Updated User List </h1>";
echo "<a href='updateUser_form.html' title= 'Click to Update User Information'> Update User </a> <br/><br/>";
echo "<table border=\"1\">";
echo "<tr><td>User ID</td><td>Name</td><td>Age</td><td>Email</td></tr>";
while ($myrow = mysql_fetch_row($result)) {
      printf("<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
      $myrow[0], $myrow[1], $myrow[2], $myrow[3]);
} echo "</table>"; ?> 
 
</body>
 </html>		
		



