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
            $sql = "SELECT * FROM origen WHERE numero_arete = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $numero_arete);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                echo json_encode($row);
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "No se encontró el origen con arete: " . $numero_arete));
            }
        } else {
            // Consultar todos los registros
            $sql = "SELECT * FROM origen ORDER BY id DESC";
            $result = $conn->query($sql);
            
            $origenes = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $origenes[] = $row;
                }
            }
            echo json_encode($origenes);
        }
        break;
        
    case 'POST':
        // Crear nuevo registro
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validar campos requeridos
        if (!isset($data['numero_arete']) || !isset($data['nombre_dueno']) || 
            !isset($data['nombre_finca']) || !isset($data['color_ganado'])) {
            http_response_code(400);
            echo json_encode(array("message" => "Todos los campos son requeridos: numero_arete, nombre_dueno, nombre_finca, color_ganado"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        $nombre_dueno = $data['nombre_dueno'];
        $nombre_finca = $data['nombre_finca'];
        $color_ganado = $data['color_ganado'];
        
        // Verificar si ya existe el número de arete
        $sql_check = "SELECT id FROM origen WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows > 0) {
            http_response_code(409);
            echo json_encode(array("message" => "Ya existe un registro con el número de arete: " . $numero_arete));
            break;
        }
        
        $sql = "INSERT INTO origen (numero_arete, nombre_dueno, nombre_finca, color_ganado) 
                VALUES (?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssss", $numero_arete, $nombre_dueno, $nombre_finca, $color_ganado);
        
        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array(
                "message" => "Origen creado exitosamente", 
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
        $nombre_dueno = isset($data['nombre_dueno']) ? $data['nombre_dueno'] : null;
        $nombre_finca = isset($data['nombre_finca']) ? $data['nombre_finca'] : null;
        $color_ganado = isset($data['color_ganado']) ? $data['color_ganado'] : null;
        
        // Verificar si existe el número de arete
        $sql_check = "SELECT id FROM origen WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("message" => "No se encontró el origen con arete: " . $numero_arete));
            break;
        }
        
        // Construir consulta dinámica
        $fields = array();
        $types = "";
        $values = array();
        
        if ($nombre_dueno !== null) {
            $fields[] = "nombre_dueno = ?";
            $types .= "s";
            $values[] = $nombre_dueno;
        }
        if ($nombre_finca !== null) {
            $fields[] = "nombre_finca = ?";
            $types .= "s";
            $values[] = $nombre_finca;
        }
        if ($color_ganado !== null) {
            $fields[] = "color_ganado = ?";
            $types .= "s";
            $values[] = $color_ganado;
        }
        
        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(array("message" => "No se proporcionaron campos para actualizar"));
            break;
        }
        
        $types .= "s";
        $values[] = $numero_arete;
        
        $sql = "UPDATE origen SET " . implode(", ", $fields) . " WHERE numero_arete = ?";
        $stmt = $conn->prepare($sql);
        
        // Enlazar parámetros dinámicamente
        $stmt->bind_param($types, ...$values);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "message" => "Origen actualizado exitosamente",
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
        $sql_check = "SELECT id FROM origen WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("message" => "No se encontró el origen con arete: " . $numero_arete));
            break;
        }
        
        $sql = "DELETE FROM origen WHERE numero_arete = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $numero_arete);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "message" => "Origen eliminado exitosamente",
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