<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"


<head>
<title>User List</title>
</head>

<style type="text/css">
th {color: maroon;
background-color: silver;}
</style>
</head>


<body>
       <a href="index.html">Home</a>
	<br/><br/>
  <tr>
     <td colspan="2" style="text-align:center"><h1>User List</h1></td>
  </tr>


<?php $db = mysql_connect("pluto", "cg16", "DBstudent15") or die("The site database appears to be down.");
    mysql_select_db("cg16db");
    

$result = mysql_query("SELECT * FROM users");
$num=mysql_numrows($result);
echo "<table border=1>\n";
echo "<tr><th>User ID</th><th>User Name</th><th> Age </th><th> Email </th></tr>\n";
$i=0;
while ($i < $num) {
printf("<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",
mysql_result($result,$i,"id"), mysql_result($result,$i,"name"),mysql_result($result,$i,"age"),mysql_result($result,$i,"email"));
$i++;
}
echo "</table>\n";
?>

<tr>
    
  </tr>

</body>
</html>
