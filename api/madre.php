<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Configuración de la base de datos
$servername = "fdb1033.awardspace.net";
$username = "4685324_ganabo";
$password = "Angelito123";
$database = "4685324_ganabo";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $database);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Método de la solicitud
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['numero_arete'])) {
            consultarMadre($conn, $_GET['numero_arete']);
        } else {
            listarMadres($conn);
        }
        break;
    
    case 'POST':
        agregarMadre($conn);
        break;
    
    case 'PUT':
        modificarMadre($conn);
        break;
    
    case 'DELETE':
        eliminarMadre($conn);
        break;
    
    default:
        echo json_encode(["success" => false, "message" => "Método no permitido"]);
        break;
}

function consultarMadre($conn, $numero_arete) {
    $stmt = $conn->prepare("SELECT * FROM madre WHERE numero_arete = ?");
    $stmt->bind_param("s", $numero_arete);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $madre = $result->fetch_assoc();
        echo json_encode(["success" => true, "data" => $madre]);
    } else {
        echo json_encode(["success" => false, "message" => "Madre no encontrada"]);
    }
    $stmt->close();
}

function listarMadres($conn) {
    $result = $conn->query("SELECT * FROM madre ORDER BY nombre_madre");
    $madres = [];
    
    while ($row = $result->fetch_assoc()) {
        $madres[] = $row;
    }
    
    echo json_encode(["success" => true, "data" => $madres]);
}

function agregarMadre($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['numero_arete']) || !isset($data['nombre_madre']) || 
        !isset($data['peso']) || !isset($data['edad']) || 
        !isset($data['altura']) || !isset($data['fecha_apareamiento'])) {
        echo json_encode(["success" => false, "message" => "Datos incompletos"]);
        return;
    }
    
    $stmt = $conn->prepare("INSERT INTO madre (numero_arete, nombre_madre, peso, edad, altura, fecha_apareamiento) 
                           VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssddds", 
        $data['numero_arete'], 
        $data['nombre_madre'], 
        $data['peso'], 
        $data['edad'], 
        $data['altura'], 
        $data['fecha_apareamiento']
    );
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Madre agregada correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al agregar: " . $stmt->error]);
    }
    $stmt->close();
}

function modificarMadre($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['numero_arete'])) {
        echo json_encode(["success" => false, "message" => "Número de arete requerido"]);
        return;
    }
    
    $stmt = $conn->prepare("UPDATE madre SET 
                          nombre_madre = ?, 
                          peso = ?, 
                          edad = ?, 
                          altura = ?, 
                          fecha_apareamiento = ? 
                          WHERE numero_arete = ?");
    $stmt->bind_param("sdddsd", 
        $data['nombre_madre'], 
        $data['peso'], 
        $data['edad'], 
        $data['altura'], 
        $data['fecha_apareamiento'], 
        $data['numero_arete']
    );
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true, "message" => "Madre actualizada correctamente"]);
        } else {
            echo json_encode(["success" => false, "message" => "No se encontró la madre o no hubo cambios"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Error al actualizar: " . $stmt->error]);
    }
    $stmt->close();
}

function eliminarMadre($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['numero_arete'])) {
        echo json_encode(["success" => false, "message" => "Número de arete requerido"]);
        return;
    }
    
    $stmt = $conn->prepare("DELETE FROM madre WHERE numero_arete = ?");
    $stmt->bind_param("s", $data['numero_arete']);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true, "message" => "Madre eliminada correctamente"]);
        } else {
            echo json_encode(["success" => false, "message" => "No se encontró la madre"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Error al eliminar: " . $stmt->error]);
    }
    $stmt->close();
}

$conn->close();
?>