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
        "Exito, Inicio De Sesion Exitoso"
    ]));
}

// Obtener y decodificar los datos JSON
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Validar campos obligatorios
if (empty($data['correo']) || empty($data['contrasena'])) {
    http_response_code(400);
    die(json_encode([
        "success" => false,
        "message" => "Faltan campos obligatorios (correo o contraseña)"
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

// Buscar usuario por correo
$stmt = $conn->prepare("SELECT id, usuario, correo, contrasena FROM usuarios WHERE correo = ?");
$stmt->bind_param("s", $data['correo']);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    // Usuario no encontrado
    http_response_code(401);
    die(json_encode([
        "success" => false,
        "message" => "Usuario no encontrado. Debe registrarse primero."
    ]));
}

$user = $result->fetch_assoc();

// Verificar contraseña
if (password_verify($data['contrasena'], $user['contrasena'])) {
    // Login exitoso
    http_response_code(200);
    echo json_encode([
        "success" => true,
        "message" => "Login exitoso",
        "user" => [
            "id" => $user['id'],
            "usuario" => $user['usuario'],
            "correo" => $user['correo']
        ]
    ]);
} else {
    // Contraseña incorrecta
    http_response_code(401);
    echo json_encode([
        "success" => false,
        "message" => "Contraseña incorrecta"
    ]);
}

$stmt->close();
$conn->close();
?>