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
        "Exito, Inicio De Sesion Exitoso"
    ]));
}

$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Aqui validamos los campos que sean obligatorios
if (empty($data['correo']) || empty($data['contrasena'])) {
    http_response_code(400);
    die(json_encode([
        "success" => false,
        "message" => "Faltan campos obligatorios (correo o contraseña)"
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

// Aqui buscamos al usuario por su correo
$stmt = $conn->prepare("SELECT id, usuario, correo, contrasena FROM usuarios WHERE correo = ?");
$stmt->bind_param("s", $data['correo']);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    http_response_code(401);
    die(json_encode([
        "success" => false,
        "message" => "Usuario no encontrado. Debe registrarse primero."
    ]));
}

$user = $result->fetch_assoc();

// Aqui verificamos la contraseña
if (password_verify($data['contrasena'], $user['contrasena'])) {
    // Aqui mostramos un mensaje de login exitoso
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
    // Aquiu mostramos un mensaje si es que la contraseña es incorrecta
    http_response_code(401);
    echo json_encode([
        "success" => false,
        "message" => "Contraseña incorrecta"
    ]);
}

$stmt->close();
$conn->close();
?>