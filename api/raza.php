<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Configuración de la base de datos
$servername = "fdb1033.awardspace.net";
$username = "4685324_ganabo"; // Cambiar por tu usuario de MySQL
$password = "Angelito123"; // Cambiar por tu contraseña de MySQL
$dbname = "4685324_ganabo";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(array("message" => "Connection failed: " . $conn->connect_error)));
}

// Obtener el método de la solicitud
$method = $_SERVER['REQUEST_METHOD'];

// Procesar según el método
switch ($method) {
    case 'GET':
        // Consultar registros
        if (isset($_GET['numero_arete'])) {
            // Consultar por número de arete
            $numero_arete = $_GET['numero_arete'];
            $sql = "SELECT * FROM raza WHERE numero_arete = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $numero_arete);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                echo json_encode($row);
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "No se encontró la raza con arete: " . $numero_arete));
            }
        } else {
            // Consultar todos los registros
            $sql = "SELECT * FROM raza ORDER BY numero_arete DESC";
            $result = $conn->query($sql);
            
            $razas = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $razas[] = $row;
                }
            }
            echo json_encode($razas);
        }
        break;
        
    case 'POST':
        // Crear nuevo registro
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validar campos requeridos
        if (!isset($data['numero_arete']) || !isset($data['nombre_raza'])) {
            http_response_code(400);
            echo json_encode(array("message" => "Los campos numero_arete y nombre_raza son requeridos"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        $peso = isset($data['peso']) ? $data['peso'] : null;
        $color_pelaje = isset($data['color_pelaje']) ? $data['color_pelaje'] : null;
        $region = isset($data['region']) ? $data['region'] : null;
        $nombre_raza = $data['nombre_raza'];
        $altura = isset($data['altura']) ? $data['altura'] : null;
        
        // Verificar si ya existe el número de arete
        $sql_check = "SELECT id FROM raza WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows > 0) {
            http_response_code(409);
            echo json_encode(array("message" => "Ya existe una raza con el número de arete: " . $numero_arete));
            break;
        }
        
        $sql = "INSERT INTO raza (numero_arete, peso, color_pelaje, region, nombre_raza, altura) 
                VALUES (?, ?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sdsssd", $numero_arete, $peso, $color_pelaje, $region, $nombre_raza, $altura);
        
        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array(
                "message" => "Raza creada exitosamente", 
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Error al crear registro: " . $conn->error));
        }
        break;
        
    case 'PUT':
        // Actualizar registro existente por número de arete
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validar campos requeridos
        if (!isset($data['numero_arete'])) {
            http_response_code(400);
            echo json_encode(array("message" => "El campo numero_arete es requerido para actualizar"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        $peso = isset($data['peso']) ? $data['peso'] : null;
        $color_pelaje = isset($data['color_pelaje']) ? $data['color_pelaje'] : null;
        $region = isset($data['region']) ? $data['region'] : null;
        $nombre_raza = isset($data['nombre_raza']) ? $data['nombre_raza'] : null;
        $altura = isset($data['altura']) ? $data['altura'] : null;
        
        // Verificar si existe el número de arete
        $sql_check = "SELECT id FROM raza WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("message" => "No se encontró la raza con arete: " . $numero_arete));
            break;
        }
        
        // Construir consulta dinámica
        $fields = array();
        $types = "";
        $values = array();
        
        if ($peso !== null) {
            $fields[] = "peso = ?";
            $types .= "d";
            $values[] = $peso;
        }
        if ($color_pelaje !== null) {
            $fields[] = "color_pelaje = ?";
            $types .= "s";
            $values[] = $color_pelaje;
        }
        if ($region !== null) {
            $fields[] = "region = ?";
            $types .= "s";
            $values[] = $region;
        }
        if ($nombre_raza !== null) {
            $fields[] = "nombre_raza = ?";
            $types .= "s";
            $values[] = $nombre_raza;
        }
        if ($altura !== null) {
            $fields[] = "altura = ?";
            $types .= "d";
            $values[] = $altura;
        }
        
        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(array("message" => "No se proporcionaron campos para actualizar"));
            break;
        }
        
        $types .= "s";
        $values[] = $numero_arete;
        
        $sql = "UPDATE raza SET " . implode(", ", $fields) . " WHERE numero_arete = ?";
        $stmt = $conn->prepare($sql);
        
        // Enlazar parámetros dinámicamente
        $stmt->bind_param($types, ...$values);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "message" => "Raza actualizada exitosamente",
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Error al actualizar registro: " . $conn->error));
        }
        break;
        
    case 'DELETE':
        // Eliminar registro por número de arete
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete'])) {
            http_response_code(400);
            echo json_encode(array("message" => "El campo numero_arete es requerido para eliminar"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        
        // Verificar si existe el número de arete
        $sql_check = "SELECT id FROM raza WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("message" => "No se encontró la raza con arete: " . $numero_arete));
            break;
        }
        
        $sql = "DELETE FROM raza WHERE numero_arete = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $numero_arete);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "message" => "Raza eliminada exitosamente",
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Error al eliminar registro: " . $conn->error));
        }
        break;
        
    default:
        // Método no permitido
        http_response_code(405);
        echo json_encode(array("message" => "Método no permitido"));
        break;
}

// Cerrar conexión
$conn->close();
?>