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
        // Aqui consultamos los datos de los trabajadores
        if (isset($_GET['numero_trabajador'])) {
            $numero_trabajador = $_GET['numero_trabajador'];
            $sql = "SELECT * FROM trabajadores WHERE numero_trabajador = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $numero_trabajador);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                echo json_encode(array("success" => true, "data" => $row));
            } else {
                http_response_code(404);
                echo json_encode(array("success" => false, "message" => "No se encontró el trabajador con número: " . $numero_trabajador));
            }
        } else {
            $sql = "SELECT * FROM trabajadores ORDER BY id DESC";
            $result = $conn->query($sql);
            
            $trabajadores = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $trabajadores[] = $row;
                }
            }
            echo json_encode(array("success" => true, "data" => $trabajadores));
        }
        break;
        
    case 'POST':
        // Aqui creamos los datos de los trabajadores
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_trabajador']) || !isset($data['nombre_completo']) || 
            !isset($data['puesto']) || !isset($data['rancho'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "Campos requeridos: numero_trabajador, nombre_completo, puesto, rancho"));
            break;
        }
        
        $numero_trabajador = $data['numero_trabajador'];
        $nombre_completo = $data['nombre_completo'];
        $puesto = $data['puesto'];
        $rancho = $data['rancho'];
        
        $sql_check = "SELECT id FROM trabajadores WHERE numero_trabajador = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_trabajador);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows > 0) {
            http_response_code(409);
            echo json_encode(array("success" => false, "message" => "Ya existe un trabajador con el número: " . $numero_trabajador));
            break;
        }
        
        $sql = "INSERT INTO trabajadores (numero_trabajador, nombre_completo, puesto, rancho) 
                VALUES (?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssss", $numero_trabajador, $nombre_completo, $puesto, $rancho);
        
        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array(
                "success" => true,
                "message" => "Trabajador registrado exitosamente", 
                "numero_trabajador" => $numero_trabajador
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al registrar trabajador: " . $conn->error));
        }
        break;
        
    case 'PUT':
        // Aqui actualizamos a los trabajadores
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validar campos requeridos
        if (!isset($data['numero_trabajador'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "El campo numero_trabajador es requerido para actualizar"));
            break;
        }
        
        $numero_trabajador = $data['numero_trabajador'];
        $nombre_completo = isset($data['nombre_completo']) ? $data['nombre_completo'] : null;
        $puesto = isset($data['puesto']) ? $data['puesto'] : null;
        $rancho = isset($data['rancho']) ? $data['rancho'] : null;
        
        $sql_check = "SELECT id FROM trabajadores WHERE numero_trabajador = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_trabajador);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("success" => false, "message" => "No se encontró el trabajador con número: " . $numero_trabajador));
            break;
        }
        
        $fields = array();
        $types = "";
        $values = array();
        
        if ($nombre_completo !== null) {
            $fields[] = "nombre_completo = ?";
            $types .= "s";
            $values[] = $nombre_completo;
        }
        if ($puesto !== null) {
            $fields[] = "puesto = ?";
            $types .= "s";
            $values[] = $puesto;
        }
        if ($rancho !== null) {
            $fields[] = "rancho = ?";
            $types .= "s";
            $values[] = $rancho;
        }
        
        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "No se proporcionaron campos para actualizar"));
            break;
        }
        
        $types .= "s";
        $values[] = $numero_trabajador;
        
        $sql = "UPDATE trabajadores SET " . implode(", ", $fields) . " WHERE numero_trabajador = ?";
        $stmt = $conn->prepare($sql);
        
        $stmt->bind_param($types, ...$values);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "success" => true,
                "message" => "Trabajador actualizado exitosamente",
                "numero_trabajador" => $numero_trabajador
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al actualizar trabajador: " . $conn->error));
        }
        break;
        
    case 'DELETE':
        // Aqui eliminamos el registro del trabajador
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['numero_trabajador'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "El campo numero_trabajador es requerido para eliminar"));
            break;
        }
        
        $numero_trabajador = $data['numero_trabajador'];
        
        $sql_check = "SELECT id FROM trabajadores WHERE numero_trabajador = ?";
        $stmt_check = $conn->prepare($sql_check);
        $stmt_check->bind_param("s", $numero_trabajador);
        $stmt_check->execute();
        $result_check = $stmt_check->get_result();
        
        if ($result_check->num_rows === 0) {
            http_response_code(404);
            echo json_encode(array("success" => false, "message" => "No se encontró el trabajador con número: " . $numero_trabajador));
            break;
        }
        
        $sql = "DELETE FROM trabajadores WHERE numero_trabajador = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $numero_trabajador);
        
        if ($stmt->execute()) {
            echo json_encode(array(
                "success" => true,
                "message" => "Trabajador eliminado exitosamente",
                "numero_trabajador" => $numero_trabajador
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error al eliminar trabajador: " . $conn->error));
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(array("success" => false, "message" => "Método no permitido"));
        break;
}

$conn->close();
?>