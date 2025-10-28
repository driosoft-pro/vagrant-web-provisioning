<?php
echo "<h1>Prueba PHP + PostgreSQL</h1>";

$dbhost = "192.168.56.11";
$dbname = "appdb";
$dbuser = "appuser";
$dbpass = "appsecret";

$conn = pg_connect("host=$dbhost dbname=$dbname user=$dbuser password=$dbpass");

if (!$conn) {
  echo "<p><strong>Error:</strong> No se pudo conectar a PostgreSQL.</p>";
  exit;
}

echo "<p>Conexión exitosa a PostgreSQL.</p>";

$result = pg_query("SELECT id, name, email FROM students;");
echo "<h3>Estudiantes registrados:</h3>";
echo "<ul>";
while ($row = pg_fetch_assoc($result)) {
  echo "<li>{$row['id']}: {$row['name']} ({$row['email']})</li>";
}
echo "</ul>";

pg_close($conn);
?>
