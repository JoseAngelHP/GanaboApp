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
        // Aqui consultamos los medicamentos
        if (isset($_GET['numero_arete'])) {
            $numero_arete = $_GET['numero_arete'];
            $sql = "SELECT * FROM medicamentos WHERE numero_arete = ? ORDER BY id DESC LIMIT 1";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $numero_arete);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                echo json_encode(array("success" => true, "data" => $row));
            } else {
                http_response_code(404);
                echo json_encode(array("success" => false, "message" => "No se encontraron medicamentos para el arete: " . $numero_arete));
            }
        } else {
            $sql = "SELECT * FROM medicamentos ORDER BY id DESC";
            $result = $conn->query($sql);
            
            $medicamentos = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $medicamentos[] = $row;
                }
            }
            echo json_encode(array("success" => true, "data" => $medicamentos));
        }
        break;
        
    case 'POST':
        // Aqui creamos un medicamento
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Aqui validamos los campos requeridos
        if (!isset($data['numero_arete']) || !isset($data['nombre_medicamento']) || 
            !isset($data['tipo_medicamento']) || !isset($data['presentacion'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "Campos requeridos: numero_arete, nombre_medicamento, tipo_medicamento, presentacion"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        $nombre_medicamento = $data['nombre_medicamento'];
        $tipo_medicamento = $data['tipo_medicamento'];
        $presentacion = $data['presentacion'];
        $indicaciones = isset($data['indicaciones']) ? $data['indicaciones'] : null;
        
        $sql = "INSERT INTO medicamentos (numero_arete, nombre_medicamento, tipo_medicamento, presentacion, indicaciones) 
                VALUES (?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sssss", $numero_arete, $nombre_medicamento, $tipo_medicamento, $presentacion, $indicaciones);
        
        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array(
                "success" => true,
                "message" => "Medicamento registrado exitosamente", 
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al registrar medicamento: " . $conn->error));
        }
        break;
        
    case 'PUT':
        // Aqui actualizamos los medicamentos
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "El campo numero_arete es requerido para actualizar"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        $nombre_medicamento = isset($data['nombre_medicamento']) ? $data['nombre_medicamento'] : null;
        $tipo_medicamento = isset($data['tipo_medicamento']) ? $data['tipo_medicamento'] : null;
        $presentacion = isset($data['presentacion']) ? $data['presentacion'] : null;
        $indicaciones = isset($data['indicaciones']) ? $data['indicaciones'] : null;
        
        $sql_check = "SELECT id FROM medicamentos WHERE numero_arete = ? ORDER BY id DESC LIMIT 1";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("success" => false, "message" => "No se encontró el medicamento con arete: " . $numero_arete));
            break;
        }
        
        $fields = array();
        $types = "";
        $values = array();
        
        if ($nombre_medicamento !== null) {
            $fields[] = "nombre_medicamento = ?";
            $types .= "s";
            $values[] = $nombre_medicamento;
        }
        if ($tipo_medicamento !== null) {
            $fields[] = "tipo_medicamento = ?";
            $types .= "s";
            $values[] = $tipo_medicamento;
        }
        if ($presentacion !== null) {
            $fields[] = "presentacion = ?";
            $types .= "s";
            $values[] = $presentacion;
        }
        if ($indicaciones !== null) {
            $fields[] = "indicaciones = ?";
            $types .= "s";
            $values[] = $indicaciones;
        }
        
        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "No se proporcionaron campos para actualizar"));
            break;
        }
        
        $types .= "s";
        $values[] = $numero_arete;
        
        $sql = "UPDATE medicamentos SET " . implode(", ", $fields) . " WHERE numero_arete = ? ORDER BY id DESC LIMIT 1";
        $stmt = $conn->prepare($sql);
        
        $stmt->bind_param($types, ...$values);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "success" => true,
                "message" => "Medicamento actualizado exitosamente",
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al actualizar medicamento: " . $conn->error));
        }
        break;
        
    case 'DELETE':
        // Aqui eliminamos los medicamentos
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "El campo numero_arete es requerido para eliminar"));
            break;
        }
        
        $numero_arete = $data['numero_arete'];
        
        $sql_check = "SELECT id FROM medicamentos WHERE numero_arete = ? ORDER BY id DESC LIMIT 1";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_arete);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("success" => false, "message" => "No se encontró el medicamento con arete: " . $numero_arete));
            break;
        }
        
        $sql = "DELETE FROM medicamentos WHERE numero_arete = ? ORDER BY id DESC LIMIT 1";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $numero_arete);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "success" => true,
                "message" => "Medicamento eliminado exitosamente",
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al eliminar medicamento: " . $conn->error));
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(array("success" => false, "message" => "Método no permitido"));
        break;
}

$conn->close();
?>