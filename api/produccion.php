<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$servername = "fdb1033.awardspace.net";//Aqui ponemos el servidor de la base de datos
$username = "4685324_ganabo";//Aqui ponemos el usuario de la base de datos
$password = "Angelito123"; //Aqui ponemos la contraseña de la base de datos
$dbname = "4685324_ganabo";//Aqui ponemos el nombre de la base de datos

// Aqui creamos la conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Aqui verificamos la conexión
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Aqui consultamos los datos de produccion
        if (isset($_GET['numero_arete'])) {
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
            $result = $conn->query("SELECT * FROM produccion ORDER BY fecha_ordeño DESC");
            $registros = array();
            
            while ($row = $result->fetch_assoc()) {
                $registros[] = $row;
            }
            echo json_encode($registros);
        }
        break;

    case 'POST':
        // Aqui creamos una produccion
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $conn->real_escape_string($data['numero_arete']);
        $fecha_ordeño = $conn->real_escape_string($data['fecha_ordeño']);
        $cantidad_leche = floatval($data['cantidad_leche']);
        $rancho_asig = $conn->real_escape_string($data['rancho_asig']);
        $persona_cargo = $conn->real_escape_string($data['persona_cargo']);
        $observaciones = isset($data['observaciones']) ? $conn->real_escape_string($data['observaciones']) : '';
        
        $stmt = $conn->prepare("INSERT INTO produccion (numero_arete, fecha_ordeño, cantidad_leche, rancho_asig, persona_cargo, observaciones) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssdsss", $numero_arete, $fecha_ordeño, $cantidad_leche, $rancho_asig, $persona_cargo, $observaciones);
        
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
        // Aqui actualizamos a produccion
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $conn->real_escape_string($data['numero_arete']);
        $nueva_fecha = $conn->real_escape_string($data['fecha_ordeño']);
        $cantidad_leche = floatval($data['cantidad_leche']);
        $rancho_asig = $conn->real_escape_string($data['rancho_asig']);
        $persona_cargo = $conn->real_escape_string($data['persona_cargo']);
        $observaciones = isset($data['observaciones']) ? $conn->real_escape_string($data['observaciones']) : '';
        
        $stmt_find = $conn->prepare("SELECT id, fecha_ordeño FROM produccion WHERE numero_arete = ? ORDER BY fecha_ordeño DESC LIMIT 1");
        $stmt_find->bind_param("s", $numero_arete);
        $stmt_find->execute();
        $result = $stmt_find->get_result();
        
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $id = $row['id'];
            $fecha_original = $row['fecha_ordeño'];
            
            $stmt_update = $conn->prepare("UPDATE produccion SET fecha_ordeño = ?, cantidad_leche = ?, rancho_asig = ?, persona_cargo = ?, observaciones = ? WHERE id = ?");
            $stmt_update->bind_param("sdsssi", $nueva_fecha, $cantidad_leche, $rancho_asig, $persona_cargo, $observaciones, $id);
            
            if ($stmt_update->execute()) {
                echo json_encode(array(
                    "message" => "Registro actualizado exitosamente",
                    "numero_arete" => $numero_arete,
                    "fecha_anterior" => $fecha_original,
                    "fecha_nueva" => $nueva_fecha
                ));
            } else {
                http_response_code(400);
                echo json_encode(array("message" => "Error al actualizar registro: " . $stmt_update->error));
            }
            $stmt_update->close();
        } else {
            http_response_code(404);
            echo json_encode(array("message" => "No se encontró registro para el número de arete $numero_arete"));
        }
        $stmt_find->close();
        break;

    case 'DELETE':
        // Aqui eliminamos la produccion
        if (isset($_GET['numero_arete'])) {
            $numero_arete = $conn->real_escape_string($_GET['numero_arete']);
            
            $stmt_find = $conn->prepare("SELECT id, fecha_ordeño FROM produccion WHERE numero_arete = ? ORDER BY fecha_ordeño DESC LIMIT 1");
            $stmt_find->bind_param("s", $numero_arete);
            $stmt_find->execute();
            $result = $stmt_find->get_result();
            
            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                $id = $row['id'];
                $fecha_ordeño = $row['fecha_ordeño'];
                
                $stmt_delete = $conn->prepare("DELETE FROM produccion WHERE id = ?");
                $stmt_delete->bind_param("i", $id);
                
                if ($stmt_delete->execute()) {
                    echo json_encode(array(
                        "message" => "Registro eliminado exitosamente",
                        "numero_arete" => $numero_arete,
                        "fecha_ordeño" => $fecha_ordeño
                    ));
                } else {
                    http_response_code(400);
                    echo json_encode(array("message" => "Error al eliminar registro: " . $stmt_delete->error));
                }
                $stmt_delete->close();
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "No se encontró registro para el número de arete $numero_arete"));
            }
            $stmt_find->close();
        } else {
            http_response_code(400);
            echo json_encode(array("message" => "Se requiere el parámetro numero_arete"));
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(array("message" => "Método no permitido"));
        break;
}

$conn->close();
?>