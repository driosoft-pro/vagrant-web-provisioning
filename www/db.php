<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Base de Datos - Vagrant</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <!-- Contenedor principal -->
  <div class="container">
    <!-- Encabezado -->
    <header class="header">
      <h1>Conexión a PostgreSQL</h1>
      <p class="subtitle">Listado de estudiantes desde la base de datos</p>
    </header>

    <!-- Botón de regreso -->
    <div class="back-button">
      <a href="index.html" class="btn btn-secondary">← Volver al inicio</a>
    </div>

    <?php
    // ==========================================
    // CONFIGURACIÓN DE CONEXIÓN A LA BASE DE DATOS
    // ==========================================
    $dbhost = "192.168.122.11";  // IP de la VM db
    $dbname = "appdb";
    $dbuser = "appuser";
    $dbpass = "appsecret";
    $dbport = "5432";

    // Construir cadena de conexión
    $connectionString = "host=$dbhost port=$dbport dbname=$dbname user=$dbuser password=$dbpass";

    try {
      // ==========================================
      // INTENTAR CONEXIÓN A POSTGRESQL
      // ==========================================
      $conn = @pg_connect($connectionString);

      if (!$conn) {
        throw new Exception("No se pudo establecer conexión con PostgreSQL");
      }

      // Verificar estado de la conexión
      $status = pg_connection_status($conn);
      if ($status !== PGSQL_CONNECTION_OK) {
        throw new Exception("La conexión a PostgreSQL no está en estado OK");
      }

      // ==========================================
      // CONEXIÓN EXITOSA - MOSTRAR INFORMACIÓN
      // ==========================================
      echo '<section class="success-section">';
      echo '<div class="alert alert-success">';
      echo '<strong>✓ Conexión exitosa</strong> a PostgreSQL en ' . htmlspecialchars($dbhost) . ':' . $dbport;
      echo '</div>';
      
      // Obtener información del servidor
      $version = pg_version($conn);
      echo '<div class="info-grid">';
      echo '<div class="info-item">';
      echo '<strong>Servidor:</strong> <span>' . htmlspecialchars($version['server'] ?? 'N/A') . '</span>';
      echo '</div>';
      echo '<div class="info-item">';
      echo '<strong>Base de datos:</strong> <span>' . htmlspecialchars($dbname) . '</span>';
      echo '</div>';
      echo '<div class="info-item">';
      echo '<strong>Usuario:</strong> <span>' . htmlspecialchars($dbuser) . '</span>';
      echo '</div>';
      echo '</div>';
      echo '</section>';

      // ==========================================
      // CONSULTAR ESTUDIANTES
      // ==========================================
      $query = "SELECT id, name, email, created_at FROM students ORDER BY id;";
      $result = pg_query($conn, $query);

      if (!$result) {
        throw new Exception("Error al ejecutar la consulta: " . pg_last_error($conn));
      }

      $numRows = pg_num_rows($result);

      echo '<section class="info-section">';
      echo '<h2>Estudiantes Registrados (' . $numRows . ')</h2>';

      if ($numRows > 0) {
        // Mostrar tabla de estudiantes
        echo '<div class="table-wrapper">';
        echo '<table class="student-table">';
        echo '<thead>';
        echo '<tr>';
        echo '<th>ID</th>';
        echo '<th>Nombre</th>';
        echo '<th>Email</th>';
        echo '<th>Fecha de Registro</th>';
        echo '</tr>';
        echo '</thead>';
        echo '<tbody>';

        while ($row = pg_fetch_assoc($result)) {
          echo '<tr>';
          echo '<td>' . htmlspecialchars($row['id']) . '</td>';
          echo '<td><strong>' . htmlspecialchars($row['name']) . '</strong></td>';
          echo '<td><code>' . htmlspecialchars($row['email']) . '</code></td>';
          echo '<td>' . htmlspecialchars($row['created_at'] ?? 'N/A') . '</td>';
          echo '</tr>';
        }

        echo '</tbody>';
        echo '</table>';
        echo '</div>';
      } else {
        echo '<div class="alert alert-warning">';
        echo 'No hay estudiantes registrados en la base de datos.';
        echo '</div>';
      }

      echo '</section>';

      // ==========================================
      // ESTADÍSTICAS ADICIONALES
      // ==========================================
      echo '<section class="info-section">';
      echo '<h3>Estadísticas</h3>';
      
      // Contar dominios de email
      $domainQuery = "SELECT split_part(email, '@', 2) as domain, COUNT(*) as count 
                      FROM students 
                      GROUP BY domain 
                      ORDER BY count DESC;";
      $domainResult = pg_query($conn, $domainQuery);
      
      if ($domainResult && pg_num_rows($domainResult) > 0) {
        echo '<h4>Dominios de email:</h4>';
        echo '<div class="stats-grid">';
        while ($domain = pg_fetch_assoc($domainResult)) {
          echo '<div class="stat-item">';
          echo '<span class="stat-label">' . htmlspecialchars($domain['domain']) . '</span>';
          echo '<span class="stat-value">' . htmlspecialchars($domain['count']) . ' estudiante(s)</span>';
          echo '</div>';
        }
        echo '</div>';
      }
      
      echo '</section>';

      // Cerrar conexión
      pg_close($conn);

    } catch (Exception $e) {
      // ==========================================
      // MANEJO DE ERRORES
      // ==========================================
      echo '<section class="error-section">';
      echo '<div class="alert alert-error">';
      echo '<strong>✗ Error de conexión</strong><br>';
      echo htmlspecialchars($e->getMessage());
      echo '</div>';
      
      echo '<div class="troubleshooting">';
      echo '<h3>Solución de problemas</h3>';
      echo '<ul>';
      echo '<li>Verifica que la VM <code>db</code> esté ejecutándose: <code>vagrant status</code></li>';
      echo '<li>Verifica la conectividad: <code>ping 192.168.122.11</code></li>';
      echo '<li>Verifica que PostgreSQL esté escuchando en el puerto 5432</li>';
      echo '<li>Revisa los logs de PostgreSQL en la VM db</li>';
      echo '<li>Verifica las reglas de firewall en la VM db</li>';
      echo '</ul>';
      echo '</div>';
      echo '</section>';
    }
    ?>

    <!-- Pie de página -->
    <footer class="footer">
      <p>Desarrollado por Deyton Riasco Ortiz | Vagrant + Libvirt</p>
    </footer>
  </div>
</body>
</html>