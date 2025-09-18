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
        // Consultar registros
        if (isset($_GET['id'])) {
            // Consultar un registro específico
            $id = $_GET['id'];
            $sql = "SELECT * FROM engorda WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("i", $id);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();
                echo json_encode($row);
            } else {
                echo json_encode(array("message" => "No se encontró el registro"));
            }
        } else {
            // Consultar todos los registros
            $sql = "SELECT * FROM engorda ORDER BY fecha_ingreso DESC";
            $result = $conn->query($sql);
            
            $engorda = array();
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $engorda[] = $row;
                }
            }
            echo json_encode($engorda);
        }
        break;
        
    case 'POST':
        // Crear nuevo registro
        $data = json_decode(file_get_contents("php://input"), true);
        
        $numero_arete = $data['numero_arete'];
        $fecha_ingreso = $data['fecha_ingreso'];
        $peso_ingreso = $data['peso_ingreso'];
        $costo_adquisicion = $data['costo_adquisicion'];
        $grupo_engorda = $data['grupo_engorda'];
        $dieta = $data['dieta'];
        $ganancia_peso = isset($data['ganancia_peso']) ? $data['ganancia_peso'] : null;
        $fecha_salida = isset($data['fecha_salida']) ? $data['fecha_salida'] : null;
        $peso_salida = isset($data['peso_salida']) ? $data['peso_salida'] : null;
        
        $sql = "INSERT INTO engorda (numero_arete, fecha_ingreso, peso_ingreso, costo_adquisicion, grupo_engorda, dieta, ganancia_peso, fecha_salida, peso_salida) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssddssdss", $numero_arete, $fecha_ingreso, $peso_ingreso, $costo_adquisicion, $grupo_engorda, $dieta, $ganancia_peso, $fecha_salida, $peso_salida);
        
        if ($stmt->execute()) {
            echo json_encode(array("message" => "Registro creado exitosamente", "id" => $conn->insert_id));
        } else {
            echo json_encode(array("message" => "Error al crear registro: " . $conn->error));
        }
        break;
        
    case 'PUT':
        // Actualizar registro existente
        $data = json_decode(file_get_contents("php://input"), true);
        
        $id = $data['id'];
        $numero_arete = $data['numero_arete'];
        $fecha_ingreso = $data['fecha_ingreso'];
        $peso_ingreso = $data['peso_ingreso'];
        $costo_adquisicion = $data['costo_adquisicion'];
        $grupo_engorda = $data['grupo_engorda'];
        $dieta = $data['dieta'];
        $ganancia_peso = isset($data['ganancia_peso']) ? $data['ganancia_peso'] : null;
        $fecha_salida = isset($data['fecha_salida']) ? $data['fecha_salida'] : null;
        $peso_salida = isset($data['peso_salida']) ? $data['peso_salida'] : null;
        
        $sql = "UPDATE engorda SET numero_arete=?, fecha_ingreso=?, peso_ingreso=?, costo_adquisicion=?, grupo_engorda=?, dieta=?, ganancia_peso=?, fecha_salida=?, peso_salida=? 
                WHERE id=?";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssddssdssi", $numero_arete, $fecha_ingreso, $peso_ingreso, $costo_adquisicion, $grupo_engorda, $dieta, $ganancia_peso, $fecha_salida, $peso_salida, $id);
        
        if ($stmt->execute()) {
            echo json_encode(array("message" => "Registro actualizado exitosamente"));
        } else {
            echo json_encode(array("message" => "Error al actualizar registro: " . $conn->error));
        }
        break;
        
    case 'DELETE':
        // Eliminar registro
        $data = json_decode(file_get_contents("php://input"), true);
        $id = $data['id'];
        
        $sql = "DELETE FROM engorda WHERE id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $id);
        
        if ($stmt->execute()) {
            echo json_encode(array("message" => "Registro eliminado exitosamente"));
        } else {
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