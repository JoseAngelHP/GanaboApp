<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$servername = "fdb1033.awardspace.net";
$username = "4685324_ganabo";
$password = "Angelito123"; 
$dbname = "4685324_ganabo";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Obtener todos los registros o por número de arete
        if (isset($_GET['numero_arete'])) {
            // Obtener registros por número de arete
            $numero_arete = $conn->real_escape_string($_GET['numero_arete']);
            $stmt = $conn->prepare("SELECT * FROM produccion WHERE numero_arete = ? ORDER BY fecha_ordeño DESC");
            $stmt->bind_param("s", $numero_arete);
            $stmt->execute();
            $result = $stmt->get_result();
            
            $registros = array();
            while ($row = $result->fetch_assoc()) {
                $registros[] = $row;
            }
            
            if (count($registros) > 0) {
                echo json_encode($registros);
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "No se encontraron registros para el número de arete: $numero_arete"));
            }
            $stmt->close();
        } else {
            // Obtener todos los registros
            $result = $conn->query("SELECT * FROM produccion ORDER BY fecha_ordeño DESC");
            $registros = array();
            
            while ($row = $result->fetch_assoc()) {
                $registros[] = $row;
            }
            echo json_encode($registros);
        }
        break;

    case 'POST':
        // Agregar nuevo registro
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $conn->real_escape_string($data['numero_arete']);
        $fecha_ordeño = $conn->real_escape_string($data['fecha_ordeño']);
        $cantidad_leche = floatval($data['cantidad_leche']);
        $calidad_leche = $conn->real_escape_string($data['calidad_leche']);
        $persona_cargo = $conn->real_escape_string($data['persona_cargo']);
        $observaciones = isset($data['observaciones']) ? $conn->real_escape_string($data['observaciones']) : '';
        
        $stmt = $conn->prepare("INSERT INTO produccion (numero_arete, fecha_ordeño, cantidad_leche, calidad_leche, persona_cargo, observaciones) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssdsss", $numero_arete, $fecha_ordeño, $cantidad_leche, $calidad_leche, $persona_cargo, $observaciones);
        
        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array(
                "message" => "Registro creado exitosamente", 
                "id" => $stmt->insert_id,
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(400);
            echo json_encode(array("message" => "Error al crear registro: " . $stmt->error));
        }
        $stmt->close();
        break;

    case 'PUT':
        // Actualizar registro existente por número de arete y fecha
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $conn->real_escape_string($data['numero_arete']);
        $fecha_ordeño = $conn->real_escape_string($data['fecha_ordeño']);
        $cantidad_leche = floatval($data['cantidad_leche']);
        $calidad_leche = $conn->real_escape_string($data['calidad_leche']);
        $persona_cargo = $conn->real_escape_string($data['persona_cargo']);
        $observaciones = isset($data['observaciones']) ? $conn->real_escape_string($data['observaciones']) : '';
        
        // Buscar el ID del registro a actualizar
        $stmt_find = $conn->prepare("SELECT id FROM produccion WHERE numero_arete = ? AND fecha_ordeño = ?");
        $stmt_find->bind_param("ss", $numero_arete, $fecha_ordeño);
        $stmt_find->execute();
        $result = $stmt_find->get_result();
        
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $id = $row['id'];
            
            // Actualizar el registro
            $stmt_update = $conn->prepare("UPDATE produccion SET cantidad_leche = ?, calidad_leche = ?, persona_cargo = ?, observaciones = ? WHERE id = ?");
            $stmt_update->bind_param("dsssi", $cantidad_leche, $calidad_leche, $persona_cargo, $observaciones, $id);
            
            if ($stmt_update->execute()) {
                echo json_encode(array(
                    "message" => "Registro actualizado exitosamente",
                    "numero_arete" => $numero_arete,
                    "fecha_ordeño" => $fecha_ordeño
                ));
            } else {
                http_response_code(400);
                echo json_encode(array("message" => "Error al actualizar registro: " . $stmt_update->error));
            }
            $stmt_update->close();
        } else {
            http_response_code(404);
            echo json_encode(array("message" => "No se encontró registro para el número de arete $numero_arete en la fecha $fecha_ordeño"));
        }
        $stmt_find->close();
        break;

    case 'DELETE':
        // Eliminar registro por número de arete y fecha
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $conn->real_escape_string($data['numero_arete']);
        $fecha_ordeño = $conn->real_escape_string($data['fecha_ordeño']);
        
        $stmt = $conn->prepare("DELETE FROM produccion WHERE numero_arete = ? AND fecha_ordeño = ?");
        $stmt->bind_param("ss", $numero_arete, $fecha_ordeño);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                echo json_encode(array(
                    "message" => "Registro eliminado exitosamente",
                    "numero_arete" => $numero_arete,
                    "fecha_ordeño" => $fecha_ordeño
                ));
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "No se encontró registro para eliminar"));
            }
        } else {
            http_response_code(400);
            echo json_encode(array("message" => "Error al eliminar registro: " . $stmt->error));
        }
        $stmt->close();
        break;

    default:
        http_response_code(405);
        echo json_encode(array("message" => "Método no permitido"));
        break;
}

$conn->close();
?>