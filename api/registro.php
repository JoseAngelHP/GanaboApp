<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    die(json_encode([
        "Exito, Datos Guardados Correctamente Al Registrarse"
    ]));
}

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (empty($data['usuario']) || empty($data['correo']) || empty($data['contrasena'])) {
    http_response_code(400);
    die(json_encode([
        "success" => false,
        "message" => "Faltan campos obligatorios",
        "campos_recibidos" => $data
    ]));
}

$servername = "fdb1033.awardspace.net";//Aqui ponemos el servidor de la base de datos
$username = "4685324_ganabo";//Aqui ponemos el usuario de la base de datos
$password = "Angelito123";//Aqui ponemos la contraseña de la base de datos
$dbname = "4685324_ganabo";//Aqui ponemos el nombre de la base de datos

// Aqui creamos la conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Aqui verificamos la conexión
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode([
        "success" => false,
        "message" => "Error de conexión a la base de datos: " . $conn->connect_error
    ]));
}

$check = $conn->prepare("SELECT id FROM usuarios WHERE usuario = ? OR correo = ?");
$check->bind_param("ss", $data['usuario'], $data['correo']);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    http_response_code(409);
    die(json_encode([
        "success" => false,
        "message" => "El usuario o correo ya está registrado"
    ]));
}
$check->close();

// Aqui insertamos un nuevo usuario
$stmt = $conn->prepare("INSERT INTO usuarios (usuario, correo, contrasena) VALUES (?, ?, ?)");
$hashedPassword = password_hash($data['contrasena'], PASSWORD_DEFAULT);
$stmt->bind_param("sss", $data['usuario'], $data['correo'], $hashedPassword);

if ($stmt->execute()) {
    // Aqui mandamos un mensaje de éxito con los datos guardados
    http_response_code(201);
    echo json_encode([
        "success" => true,
        "message" => "Datos guardados exitosamente",
        "datos_guardados" => [
            "usuario" => $data['usuario'],
            "correo" => $data['correo'],
            "id" => $stmt->insert_id
        ]
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Error al registrar usuario: " . $conn->error
    ]);
}

$stmt->close();
$conn->close();
?>