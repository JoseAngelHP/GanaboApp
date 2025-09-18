<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Configuración de la base de datos
$servidor = "fdb1033.awardspace.net";
$usuario = "4685324_ganabo";     // ← Cambia por tu usuario
$password = "Angelito123";   // ← Cambia por tu password
$basedatos = "4685324_ganabo";        // ← Cambia por el nombre de tu BD

// Crear conexión
$conexion = new mysqli($servidor, $usuario, $password, $basedatos);

// Verificar conexión
if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

// Consulta para obtener las razas
$sql = "SELECT nombre_raza FROM raza";
$resultado = $conexion->query($sql);

$razas = array();

if ($resultado->num_rows > 0) {
    while($fila = $resultado->fetch_assoc()) {
        $razas[] = $fila['nombre_raza'];
    }
}

echo json_encode($razas);
$conexion->close();
?>