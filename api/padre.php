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
        // CONSULTAR - Obtener todos los registros o uno específico
        if (isset($_GET['numero_arete'])) {
            consultarPadre($conn, $_GET['numero_arete']);
        } else {
            listarPadres($conn);
        }
        break;
    
    case 'POST':
        // AGREGAR - Crear nuevo registro
        agregarPadre($conn);
        break;
    
    case 'PUT':
        // MODIFICAR - Actualizar registro
        modificarPadre($conn);
        break;
    
    case 'DELETE':
        // ELIMINAR - Borrar registro
        eliminarPadre($conn);
        break;
    
    default:
        echo json_encode(["success" => false, "message" => "Método no permitido"]);
        break;
}

// FUNCIÓN PARA CONSULTAR UN PADRE ESPECÍFICO
function consultarPadre($conn, $numero_arete) {
    $stmt = $conn->prepare("SELECT * FROM padre WHERE numero_arete = ?");
    $stmt->bind_param("s", $numero_arete);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $padre = $result->fetch_assoc();
        echo json_encode(["success" => true, "data" => $padre]);
    } else {
        echo json_encode(["success" => false, "message" => "Padre no encontrado"]);
    }
    $stmt->close();
}

// FUNCIÓN PARA LISTAR TODOS LOS PADRES
function listarPadres($conn) {
    $result = $conn->query("SELECT * FROM padre ORDER BY nombre_padre");
    $padres = [];
    
    while ($row = $result->fetch_assoc()) {
        $padres[] = $row;
    }
    
    echo json_encode(["success" => true, "data" => $padres]);
}

// FUNCIÓN PARA AGREGAR NUEVO PADRE
function agregarPadre($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['numero_arete']) || !isset($data['nombre_padre']) || 
        !isset($data['peso']) || !isset($data['edad']) || 
        !isset($data['altura']) || !isset($data['fecha_apareamiento'])) {
        echo json_encode(["success" => false, "message" => "Datos incompletos"]);
        return;
    }
    
    $stmt = $conn->prepare("INSERT INTO padre (numero_arete, nombre_padre, peso, edad, altura, fecha_apareamiento) 
                           VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssddds", 
        $data['numero_arete'], 
        $data['nombre_padre'], 
        $data['peso'], 
        $data['edad'], 
        $data['altura'], 
        $data['fecha_apareamiento']
    );
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Padre agregado correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al agregar: " . $stmt->error]);
    }
    $stmt->close();
}

// FUNCIÓN PARA MODIFICAR PADRE
function modificarPadre($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['numero_arete'])) {
        echo json_encode(["success" => false, "message" => "Número de arete requerido"]);
        return;
    }
    
    $stmt = $conn->prepare("UPDATE padre SET 
                          nombre_padre = ?, 
                          peso = ?, 
                          edad = ?, 
                          altura = ?, 
                          fecha_apareamiento = ? 
                          WHERE numero_arete = ?");
    $stmt->bind_param("sdddsd", 
        $data['nombre_padre'], 
        $data['peso'], 
        $data['edad'], 
        $data['altura'], 
        $data['fecha_apareamiento'], 
        $data['numero_arete']
    );
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true, "message" => "Padre actualizado correctamente"]);
        } else {
            echo json_encode(["success" => false, "message" => "No se encontró el padre o no hubo cambios"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Error al actualizar: " . $stmt->error]);
    }
    $stmt->close();
}

// FUNCIÓN PARA ELIMINAR PADRE
function eliminarPadre($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['numero_arete'])) {
        echo json_encode(["success" => false, "message" => "Número de arete requerido"]);
        return;
    }
    
    $stmt = $conn->prepare("DELETE FROM padre WHERE numero_arete = ?");
    $stmt->bind_param("s", $data['numero_arete']);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true, "message" => "Padre eliminado correctamente"]);
        } else {
            echo json_encode(["success" => false, "message" => "No se encontró el padre"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Error al eliminar: " . $stmt->error]);
    }
    $stmt->close();
}

// Cerrar conexión
$conn->close();
?>