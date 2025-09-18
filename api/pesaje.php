<?php
// pesaje.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Configuración de la base de datos
$host = "fdb1033.awardspace.net";
$username = "4685324_ganabo";
$password = "Angelito123";
$dbname = "4685324_ganabo";

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    // Conexión a la base de datos
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Obtener el método de la solicitud
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
    // Obtener pesajes por ID, por número de arete, o todos
    if (isset($_GET['id'])) {
        // Buscar por ID
        $stmt = $pdo->prepare("SELECT * FROM pesaje WHERE id = ?");
        $stmt->execute([$_GET['id']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
    } elseif (isset($_GET['numero_arete'])) {
        // Buscar por número de arete
        $stmt = $pdo->prepare("SELECT * FROM pesaje WHERE numero_arete = ? ORDER BY fecha_pesaje DESC");
        $stmt->execute([$_GET['numero_arete']]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } else {
        // Obtener todos los pesajes
        $stmt = $pdo->query("SELECT * FROM pesaje ORDER BY fecha_pesaje DESC");
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    echo json_encode(['success' => true, 'data' => $result]);
    break;
            
        case 'POST':
            // Insertar nuevo pesaje
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Validar datos requeridos
            if (!isset($data['numero_arete']) || !isset($data['fecha_pesaje']) || 
                !isset($data['peso']) || !isset($data['persona_cargo'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Datos incompletos']);
                exit();
            }
            
            $stmt = $pdo->prepare("
                INSERT INTO pesaje 
                (numero_arete, fecha_pesaje, peso, ubicacion_direccion, persona_cargo, observaciones) 
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            
            $stmt->execute([
                $data['numero_arete'],
                $data['fecha_pesaje'],
                $data['peso'],
                $data['ubicacion_direccion'] ?? null,
                $data['persona_cargo'],
                $data['observaciones'] ?? null
            ]);
            
            $id = $pdo->lastInsertId();
            echo json_encode(['success' => true, 'id' => $id, 'message' => 'Pesaje guardado correctamente']);
            break;
            
        case 'PUT':
            // Actualizar pesaje
            $data = json_decode(file_get_contents('php://input'), true);
            $id = $_GET['id'];
            
            $stmt = $pdo->prepare("
                UPDATE pesaje SET 
                numero_arete = ?, fecha_pesaje = ?, peso = ?, 
                ubicacion_direccion = ?, persona_cargo = ?, observaciones = ?
                WHERE id = ?
            ");
            
            $stmt->execute([
                $data['numero_arete'],
                $data['fecha_pesaje'],
                $data['peso'],
                $data['ubicacion_direccion'] ?? null,
                $data['persona_cargo'],
                $data['observaciones'] ?? null,
                $id
            ]);
            
            echo json_encode(['success' => true, 'message' => 'Pesaje actualizado correctamente']);
            break;
            
        case 'DELETE':
    // Eliminar pesaje por ID o por número de arete
    if (isset($_GET['id'])) {
        $stmt = $pdo->prepare("DELETE FROM pesaje WHERE id = ?");
        $stmt->execute([$_GET['id']]);
        echo json_encode(['success' => true, 'message' => 'Pesaje eliminado correctamente']);
    } elseif (isset($_GET['numero_arete'])) {
        $stmt = $pdo->prepare("DELETE FROM pesaje WHERE numero_arete = ?");
        $stmt->execute([$_GET['numero_arete']]);
        echo json_encode(['success' => true, 'message' => 'Todos los pesajes del arete eliminados correctamente']);
    } else {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Se requiere ID o número de arete']);
    }
    break;
            
        default:
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Método no permitido']);
            break;
    }
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error de base de datos: ' . $e->getMessage()]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>