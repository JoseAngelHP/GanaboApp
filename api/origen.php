<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$servername = "fdb1033.awardspace.net";//Aqui ponemos el servidor de la base de datos
$username = "4685324_ganabo";//Aqui ponemos el usuario de la base de datos
$password = "Angelito123";//Aqui ponemos la contraseña de la base de datos
$dbname = "4685324_ganabo";//Aqui ponemos el nombre de la base de datos

// Aqui creamos la conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Aqui verificamos la conexión
if ($conn->connect_error) {
    die(json_encode(array("success" => false, "message" => "Connection failed: " . $conn->connect_error)));
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Aqui consultamos el origen
        if (isset($_GET['numero_arete'])) {
            $numero_arete = $_GET['numero_arete'];
            $sql = "SELECT * FROM origen WHERE numero_arete = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $numero_arete);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                echo json_encode(array("success" => true, "data" => $row));
            } else {
                http_response_code(404);
                echo json_encode(array("success" => false, "message" => "No se encontró el origen con arete: " . $numero_arete));
            }
        } else {
            $sql = "SELECT * FROM origen ORDER BY id DESC";
            $result = $conn->query($sql);
            
            $origenes = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $origenes[] = $row;
                }
            }
            echo json_encode(array("success" => true, "data" => $origenes));
        }
        break;
        
    case 'POST':
        // Aqui creamos un nuevo origen
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete']) || !isset($data['nombre_dueno']) || 
            !isset($data['nombre_finca'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "Campos requeridos: numero_arete, nombre_dueno, nombre_finca"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        $nombre_dueno = $data['nombre_dueno'];
        $nombre_finca = $data['nombre_finca'];
        $ext_hecta = isset($data['ext_hecta']) ? $data['ext_hecta'] : null;
        $ubicacion_direccion = isset($data['ubicacion_direccion']) ? $data['ubicacion_direccion'] : null;
        
        $sql_check = "SELECT id FROM origen WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows > 0) {
            http_response_code(409);
            echo json_encode(array("success" => false, "message" => "Ya existe un registro con el número de arete: " . $numero_arete));
            break;
        }
        
        $sql = "INSERT INTO origen (numero_arete, nombre_dueno, nombre_finca, ext_hecta, ubicacion_direccion) 
                VALUES (?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sssds", $numero_arete, $nombre_dueno, $nombre_finca, $ext_hecta, $ubicacion_direccion);
        
        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array(
                "success" => true,
                "message" => "Origen creado exitosamente", 
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al crear registro: " . $conn->error));
        }
        break;
        
    case 'PUT':
        // Aqui actualizamos el origen
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "El campo numero_arete es requerido para actualizar"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        $nombre_dueno = isset($data['nombre_dueno']) ? $data['nombre_dueno'] : null;
        $nombre_finca = isset($data['nombre_finca']) ? $data['nombre_finca'] : null;
        $ext_hecta = isset($data['ext_hecta']) ? $data['ext_hecta'] : null;
        $ubicacion_direccion = isset($data['ubicacion_direccion']) ? $data['ubicacion_direccion'] : null;
        
        $sql_check = "SELECT id FROM origen WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("success" => false, "message" => "No se encontró el origen con arete: " . $numero_arete));
            break;
        }
        
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
        if ($ext_hecta !== null) {
            $fields[] = "ext_hecta = ?";
            $types .= "d";
            $values[] = $ext_hecta;
        }
        if ($ubicacion_direccion !== null) {
            $fields[] = "ubicacion_direccion = ?";
            $types .= "s";
            $values[] = $ubicacion_direccion;
        }
        
        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "No se proporcionaron campos para actualizar"));
            break;
        }
        
        $types .= "s";
        $values[] = $numero_arete;
        
        $sql = "UPDATE origen SET " . implode(", ", $fields) . " WHERE numero_arete = ?";
        $stmt = $conn->prepare($sql);
        
        $stmt->bind_param($types, ...$values);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "success" => true,
                "message" => "Origen actualizado exitosamente",
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al actualizar registro: " . $conn->error));
        }
        break;
        
    case 'DELETE':
        // Aqui eliminamos el origen
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "El campo numero_arete es requerido para eliminar"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        
        $sql_check = "SELECT id FROM origen WHERE numero_arete = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("success" => false, "message" => "No se encontró el origen con arete: " . $numero_arete));
            break;
        }
        
        $sql = "DELETE FROM origen WHERE numero_arete = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $numero_arete);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "success" => true,
                "message" => "Origen eliminado exitosamente",
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al eliminar registro: " . $conn->error));
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(array("success" => false, "message" => "Método no permitido"));
        break;
}

$conn->close();
?>