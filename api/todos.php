<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$servidor = "fdb1033.awardspace.net";//Aqui ponemos el servidor de la base de datos
$usuario = "4685324_ganabo"; //Aqui ponemos el usuario de la base de datos
$password = "Angelito123"; //Aqui ponemos la contraseña de la base de datos
$basedatos = "4685324_ganabo"; //Aqui ponemos el nombre de la base de datos

// Aqui creamos la conexión
$conexion = new mysqli($servidor, $usuario, $password, $basedatos);

// Aqui verificamos la conexión
if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

// Aqui hacemos la consulta para obtener las razas
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