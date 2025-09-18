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
    die("Connection failed: " . $conn->connect_error);
}

// Obtener el método de la solicitud
$method = $_SERVER['REQUEST_METHOD'];

// Procesar según el método
switch ($method) {
    case 'GET':
        // Consultar registros por número de arete
        if (isset($_GET['numero_arete'])) {
            $numero_arete = $_GET['numero_arete'];
            
            // Consultar todos los registros del animal
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
            
            echo json_encode($vacunaciones); // Devolver array de registros
        } else {
            // Consultar todos los registros
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
        // Crear nuevo registro de vacunación
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $data['numero_arete'];
        $fecha_vacunacion = $data['fecha_vacunacion'];
        $vacuna_aplicada = $data['vacuna_aplicada'];
        $via_administracion = $data['via_administracion'];
        $dosis = $data['dosis'];
        $aplicador = $data['aplicador'];
        $proxima_vacunacion = isset($data['proxima_vacunacion']) ? $data['proxima_vacunacion'] : null;
        $observaciones = isset($data['observaciones']) ? $data['observaciones'] : null;
        
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
            echo json_encode(array("message" => "Error al crear registro: " . $conn->error));
        }
        break;
        
    case 'PUT':
        // Actualizar el ÚLTIMO registro de vacunación por número de arete
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $data['numero_arete'];
        $fecha_vacunacion = $data['fecha_vacunacion'];
        $vacuna_aplicada = $data['vacuna_aplicada'];
        $via_administracion = $data['via_administracion'];
        $dosis = $data['dosis'];
        $aplicador = $data['aplicador'];
        $proxima_vacunacion = isset($data['proxima_vacunacion']) ? $data['proxima_vacunacion'] : null;
        $observaciones = isset($data['observaciones']) ? $data['observaciones'] : null;
        
        // Primero obtener el ID del último registro para este número de arete
        $sql_get_last = "SELECT id FROM vacunacion WHERE numero_arete = ? ORDER BY fecha_vacunacion DESC LIMIT 1";
        $stmt_get_last = $conn->prepare($sql_get_last);
        $stmt_get_last->bind_param("s", $numero_arete);
        $stmt_get_last->execute();
        $result_get_last = $stmt_get_last->get_result();
        
        if ($result_get_last->num_rows > 0) {
            $last_record = $result_get_last->fetch_assoc();
            $record_id = $last_record['id'];
            
            // Actualizar el último registro
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
                echo json_encode(array("message" => "Error al actualizar registro: " . $conn->error));
            }
        } else {
            echo json_encode(array("message" => "No se encontraron registros para este número de arete"));
        }
        break;
        
    case 'DELETE':
        // Eliminar TODOS los registros de vacunación por número de arete
        $data = json_decode(file_get_contents("php://input"), true);
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
                echo json_encode(array("message" => "No se encontraron registros para eliminar"));
            }
        } else {
            echo json_encode(array("message" => "Error al eliminar registros: " . $conn->error));
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