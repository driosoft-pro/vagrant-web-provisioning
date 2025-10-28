<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Información PHP - Vagrant</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <!-- Contenedor principal -->
  <div class="container">
    <!-- Encabezado -->
    <header class="header">
      <h1>Información de PHP</h1>
      <p class="subtitle">Detalles de configuración y módulos</p>
    </header>

    <!-- Botón de regreso -->
    <div class="back-button">
      <a href="index.html" class="btn btn-secondary">← Volver al inicio</a>
    </div>

    <!-- Sección de información PHP -->
    <section class="info-section">
      <h2>Versión y Configuración</h2>
      
      <?php
      // Obtener información básica de PHP
      $phpVersion = phpversion();
      $phpSapi = php_sapi_name();
      $phpOS = PHP_OS;
      ?>

      <div class="info-grid">
        <div class="info-item">
          <strong>Versión PHP:</strong>
          <span><?php echo $phpVersion; ?></span>
        </div>
        <div class="info-item">
          <strong>SAPI:</strong>
          <span><?php echo $phpSapi; ?></span>
        </div>
        <div class="info-item">
          <strong>Sistema Operativo:</strong>
          <span><?php echo $phpOS; ?></span>
        </div>
        <div class="info-item">
          <strong>Servidor:</strong>
          <span><?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'N/A'; ?></span>
        </div>
      </div>
    </section>

    <!-- Módulos cargados -->
    <section class="info-section">
      <h2>Módulos Cargados</h2>
      
      <?php
      // Obtener extensiones cargadas
      $extensions = get_loaded_extensions();
      sort($extensions);
      
      // Verificar módulos importantes
      $importantModules = ['pgsql', 'pdo_pgsql', 'mbstring', 'curl', 'json'];
      ?>

      <div class="module-check">
        <h3>Módulos Importantes:</h3>
        <ul>
          <?php foreach ($importantModules as $module): ?>
            <li class="<?php echo extension_loaded($module) ? 'success' : 'error'; ?>">
              <span class="status-icon"><?php echo extension_loaded($module) ? '✓' : '✗'; ?></span>
              <?php echo $module; ?>
              <?php echo extension_loaded($module) ? '(Instalado)' : '(No disponible)'; ?>
            </li>
          <?php endforeach; ?>
        </ul>
      </div>

      <details class="extension-details">
        <summary>Ver todas las extensiones (<?php echo count($extensions); ?>)</summary>
        <div class="extension-grid">
          <?php foreach ($extensions as $ext): ?>
            <span class="badge"><?php echo $ext; ?></span>
          <?php endforeach; ?>
        </div>
      </details>
    </section>

    <!-- Sección de phpinfo completa (colapsable) -->
    <section class="info-section">
      <h2>🔧 Información Completa de PHP</h2>
      <details>
        <summary>Mostrar phpinfo() completo</summary>
        <div class="phpinfo-wrapper">
          <?php
          // Capturar phpinfo() en un buffer
          ob_start();
          phpinfo();
          $phpinfo = ob_get_clean();
          
          // Limpiar estilos inline de phpinfo para usar nuestros estilos
          $phpinfo = preg_replace('%^.*<body>(.*)</body>.*$%ms', '$1', $phpinfo);
          echo $phpinfo;
          ?>
        </div>
      </details>
    </section>

    <!-- Pie de página -->
    <footer class="footer">
      <p>Desarrollado por Deyton Riasco Ortiz | Vagrant + Libvirt</p>
    </footer>
  </div>
</body>
</html>