<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

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
        // Aqui consultamos los registros de la vacunacion
        if (isset($_GET['numero_arete'])) {
            $numero_arete = $_GET['numero_arete'];
            
            $sql = "SELECT * FROM vacunacion WHERE numero_arete = ? ORDER BY fecha_vacunacion DESC";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $numero_arete);
            
            $stmt->execute();
            $result = $stmt->get_result();
            
            $vacunaciones = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $vacunaciones[] = $row;
                }
            }
            
            echo json_encode($vacunaciones);
        } else {
            $sql = "SELECT * FROM vacunacion ORDER BY numero_arete, fecha_vacunacion DESC";
            $result = $conn->query($sql);
            
            $vacunaciones = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $vacunaciones[] = $row;
                }
            }
            echo json_encode($vacunaciones);
        }
        break;
        
    case 'POST':
        // Aqui creamos un nuevo registro de vacunación
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete']) || !isset($data['fecha_vacunacion']) || 
            !isset($data['vacuna_aplicada']) || !isset($data['via_administracion']) || 
            !isset($data['dosis']) || !isset($data['aplicador'])) {
            http_response_code(400);
            echo json_encode(array("message" => "Campos requeridos faltantes"));
            exit();
        }
        
        $numero_arete = $data['numero_arete'];
        $fecha_vacunacion = $data['fecha_vacunacion'];
        $vacuna_aplicada = $data['vacuna_aplicada'];
        $via_administracion = $data['via_administracion'];
        $dosis = $data['dosis'];
        $aplicador = $data['aplicador'];
        
        $proxima_vacunacion = (isset($data['proxima_vacunacion']) && !empty($data['proxima_vacunacion'])) 
            ? $data['proxima_vacunacion'] 
            : NULL;
            
        $observaciones = (isset($data['observaciones']) && !empty($data['observaciones'])) 
            ? $data['observaciones'] 
            : NULL;
        
        $sql = "INSERT INTO vacunacion (numero_arete, fecha_vacunacion, vacuna_aplicada, via_administracion, dosis, aplicador, proxima_vacunacion, observaciones) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssdsss", $numero_arete, $fecha_vacunacion, $vacuna_aplicada, $via_administracion, $dosis, $aplicador, $proxima_vacunacion, $observaciones);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "message" => "Registro de vacunación creado exitosamente", 
                "numero_arete" => $numero_arete
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Error al crear registro: " . $stmt->error));
        }
        $stmt->close();
        break;
        
    case 'PUT':
        // Aqui actualizamos el registro de vacunación
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete']) || !isset($data['fecha_vacunacion']) || 
            !isset($data['vacuna_aplicada']) || !isset($data['via_administracion']) || 
            !isset($data['dosis']) || !isset($data['aplicador'])) {
            http_response_code(400);
            echo json_encode(array("message" => "Campos requeridos faltantes"));
            exit();
        }
        
        $numero_arete = $data['numero_arete'];
        $fecha_vacunacion = $data['fecha_vacunacion'];
        $vacuna_aplicada = $data['vacuna_aplicada'];
        $via_administracion = $data['via_administracion'];
        $dosis = $data['dosis'];
        $aplicador = $data['aplicador'];
        
        $proxima_vacunacion = (isset($data['proxima_vacunacion']) && !empty($data['proxima_vacunacion'])) 
            ? $data['proxima_vacunacion'] 
            : NULL;
            
        $observaciones = (isset($data['observaciones']) && !empty($data['observaciones'])) 
            ? $data['observaciones'] 
            : NULL;
        
        $sql_get_last = "SELECT id FROM vacunacion WHERE numero_arete = ? ORDER BY fecha_vacunacion DESC LIMIT 1";
        $stmt_get_last = $conn->prepare($sql_get_last);
        $stmt_get_last->bind_param("s", $numero_arete);
        $stmt_get_last->execute();
        $result_get_last = $stmt_get_last->get_result();
        
        if ($result_get_last->num_rows > 0) {
            $last_record = $result_get_last->fetch_assoc();
            $record_id = $last_record['id'];
            
            $sql = "UPDATE vacunacion SET 
                    fecha_vacunacion = ?,
                    vacuna_aplicada = ?, 
                    via_administracion = ?, 
                    dosis = ?, 
                    aplicador = ?, 
                    proxima_vacunacion = ?, 
                    observaciones = ? 
                    WHERE id = ?";
            
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("sssdsssi", $fecha_vacunacion, $vacuna_aplicada, $via_administracion, $dosis, $aplicador, $proxima_vacunacion, $observaciones, $record_id);
            
            if ($stmt->execute()) {
                if ($stmt->affected_rows > 0) {
                    echo json_encode(array(
                        "message" => "Último registro de vacunación actualizado exitosamente",
                        "numero_arete" => $numero_arete,
                        "fecha_vacunacion" => $fecha_vacunacion
                    ));
                } else {
                    echo json_encode(array("message" => "No se pudo actualizar el registro"));
                }
            } else {
                http_response_code(500);
                echo json_encode(array("message" => "Error al actualizar registro: " . $stmt->error));
            }
            $stmt->close();
        } else {
            http_response_code(404);
            echo json_encode(array("message" => "No se encontraron registros para este número de arete"));
        }
        $stmt_get_last->close();
        break;
        
    case 'DELETE':
        // Aqui eliminamos los registros de vacunación 
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_arete'])) {
            http_response_code(400);
            echo json_encode(array("message" => "Se requiere el número de arete"));
            exit();
        }
        
        $numero_arete = $data['numero_arete'];
        
        $sql = "DELETE FROM vacunacion WHERE numero_arete = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $numero_arete);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                echo json_encode(array(
                    "message" => "Todos los registros de vacunación eliminados exitosamente",
                    "numero_arete" => $numero_arete,
                    "registros_eliminados" => $stmt->affected_rows
                ));
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "No se encontraron registros para eliminar"));
            }
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Error al eliminar registros: " . $stmt->error));
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