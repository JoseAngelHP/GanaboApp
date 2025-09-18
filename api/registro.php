<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Manejar preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Verificar método POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    die(json_encode([
        "Exito, Datos Guardados Correctamente Al Registrarse"
    ]));
}

// Obtener y decodificar los datos JSON
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Validar campos obligatorios
if (empty($data['usuario']) || empty($data['correo']) || empty($data['contrasena'])) {
    http_response_code(400);
    die(json_encode([
        "success" => false,
        "message" => "Faltan campos obligatorios",
        "campos_recibidos" => $data
    ]));
}

// Configuración de la base de datos
$servername = "fdb1033.awardspace.net";
$username = "4685324_ganabo";
$password = "Angelito123";
$dbname = "4685324_ganabo";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode([
        "success" => false,
        "message" => "Error de conexión a la base de datos: " . $conn->connect_error
    ]));
}

// Verificar si el usuario ya existe
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

// Insertar nuevo usuario
$stmt = $conn->prepare("INSERT INTO usuarios (usuario, correo, contrasena) VALUES (?, ?, ?)");
$hashedPassword = password_hash($data['contrasena'], PASSWORD_DEFAULT);
$stmt->bind_param("sss", $data['usuario'], $data['correo'], $hashedPassword);

if ($stmt->execute()) {
    // Respuesta de éxito con los datos guardados
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