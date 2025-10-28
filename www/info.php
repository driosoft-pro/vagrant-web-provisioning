<?php
// Configuración de conexión a PostgreSQL
$cfg = [
  'host' => '192.168.56.11',
  'port' => '5432',
  'dbname' => 'appdb',
  'user' => 'appuser',
  'password' => 'appsecret',
];

// Mostrar información básica y enlace a phpinfo()
echo "<h1>PHP + PostgreSQL demo</h1>";
echo "<p><a href='?phpinfo=1'>Ver phpinfo()</a></p>";

// Mostrar phpinfo() si se solicita
if (isset($_GET['phpinfo'])) {
  phpinfo();
  exit;
}

// Conectar a PostgreSQL
$conn_str = sprintf(
  "host=%s port=%s dbname=%s user=%s password=%s",
  $cfg['host'], $cfg['port'], $cfg['dbname'], $cfg['user'], $cfg['password']
);

// Intentar la conexión
$conn = @pg_connect($conn_str);

// Verificar la conexión
if (!$conn) {
  echo "<p style='color:red'>No se pudo conectar a PostgreSQL en {$cfg['host']}.</p>";
  exit;
}

// Ejecutar consulta para obtener datos de la tabla 'students'
$res = pg_query($conn, "SELECT id, name, email FROM students ORDER BY id ASC");
if (!$res) {
  echo "<p style='color:red'>La consulta falló.</p>";
  exit;
}

// Mostrar los resultados en una tabla HTML
echo "<table border='1' cellpadding='6'><tr><th>ID</th><th>Nombre</th><th>Email</th></tr>";
while ($row = pg_fetch_assoc($res)) {
  echo "<tr><td>{$row['id']}</td><td>{$row['name']}</td><td>{$row['email']}</td></tr>";
}
// Cerrar la tabla HTML
echo "</table>";

// Liberar resultados y cerrar la conexión
pg_free_result($res);
pg_close($conn);
?>
