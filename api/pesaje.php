<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

$host = "fdb1033.awardspace.net";//Aqui ponemos el servidor de la base de datos
$username = "4685324_ganabo";//Aqui ponemos el usuario de la base de datos
$password = "Angelito123";//Aqui ponemos la contraseña de la base de datos
$dbname = "4685324_ganabo";//Aqui ponemos el nombre de la base de datos

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    // Aqui creamos la conexión
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            // Aqui consultamos los datos del pesaje
            if (isset($_GET['id'])) {
                $stmt = $pdo->prepare("SELECT * FROM pesaje WHERE id = ?");
                $stmt->execute([$_GET['id']]);
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
            } elseif (isset($_GET['numero_arete'])) {
                $stmt = $pdo->prepare("SELECT * FROM pesaje WHERE numero_arete = ? ORDER BY fecha_pesaje DESC");
                $stmt->execute([$_GET['numero_arete']]);
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            } else {
                $stmt = $pdo->query("SELECT * FROM pesaje ORDER BY fecha_pesaje DESC");
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            }
            
            echo json_encode(['success' => true, 'data' => $result]);
            break;
            
        case 'POST':
            // Aqui insertamos un nuevo pesaje
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($data['numero_arete']) || !isset($data['fecha_pesaje']) || 
                !isset($data['peso']) || !isset($data['persona_cargo']) || 
                !isset($data['ubicacion_direccion'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Datos incompletos. Campos requeridos: numero_arete, fecha_pesaje, peso, persona_cargo, ubicacion_direccion']);
                exit();
            }
            
            if (!is_numeric($data['peso'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'El peso debe ser un valor numérico']);
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
                floatval($data['peso']), 
                $data['ubicacion_direccion'], 
                $data['persona_cargo'],
                $data['observaciones'] ?? null
            ]);
            
            $id = $pdo->lastInsertId();
            echo json_encode([
                'success' => true, 
                'id' => $id, 
                'message' => 'Pesaje guardado correctamente',
                'numero_arete' => $data['numero_arete']
            ]);
            break;
            
        case 'PUT':
            // Aqui actualizamos el pesaje
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Se requiere el ID para actualizar']);
                exit();
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            $id = $_GET['id'];
            
            $stmtCheck = $pdo->prepare("SELECT id FROM pesaje WHERE id = ?");
            $stmtCheck->execute([$id]);
            if (!$stmtCheck->fetch()) {
                http_response_code(404);
                echo json_encode(['success' => false, 'message' => 'Pesaje no encontrado']);
                exit();
            }
            
            if (!isset($data['numero_arete']) || !isset($data['fecha_pesaje']) || 
                !isset($data['peso']) || !isset($data['persona_cargo']) || 
                !isset($data['ubicacion_direccion'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Datos incompletos para actualización']);
                exit();
            }
            
            if (!is_numeric($data['peso'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'El peso debe ser un valor numérico']);
                exit();
            }
            
            $stmt = $pdo->prepare("
                UPDATE pesaje SET 
                numero_arete = ?, fecha_pesaje = ?, peso = ?, 
                ubicacion_direccion = ?, persona_cargo = ?, observaciones = ?
                WHERE id = ?
            ");
            
            $stmt->execute([
                $data['numero_arete'],
                $data['fecha_pesaje'],
                floatval($data['peso']),
                $data['ubicacion_direccion'],
                $data['persona_cargo'],
                $data['observaciones'] ?? null,
                $id
            ]);
            
            echo json_encode([
                'success' => true, 
                'message' => 'Pesaje actualizado correctamente',
                'id' => $id
            ]);
            break;
            
        case 'DELETE':
            // Aqui eliminamos el pesaje
            if (isset($_GET['id'])) {
                $stmtCheck = $pdo->prepare("SELECT id FROM pesaje WHERE id = ?");
                $stmtCheck->execute([$_GET['id']]);
                if (!$stmtCheck->fetch()) {
                    http_response_code(404);
                    echo json_encode(['success' => false, 'message' => 'Pesaje no encontrado']);
                    exit();
                }
                
                $stmt = $pdo->prepare("DELETE FROM pesaje WHERE id = ?");
                $stmt->execute([$_GET['id']]);
                echo json_encode([
                    'success' => true, 
                    'message' => 'Pesaje eliminado correctamente',
                    'id' => $_GET['id']
                ]);
            } elseif (isset($_GET['numero_arete'])) {
                $stmtCheck = $pdo->prepare("SELECT COUNT(*) as count FROM pesaje WHERE numero_arete = ?");
                $stmtCheck->execute([$_GET['numero_arete']]);
                $count = $stmtCheck->fetch(PDO::FETCH_ASSOC)['count'];
                
                if ($count == 0) {
                    http_response_code(404);
                    echo json_encode(['success' => false, 'message' => 'No se encontraron pesajes para el arete especificado']);
                    exit();
                }
                
                $stmt = $pdo->prepare("DELETE FROM pesaje WHERE numero_arete = ?");
                $stmt->execute([$_GET['numero_arete']]);
                echo json_encode([
                    'success' => true, 
                    'message' => "$count pesaje(s) eliminado(s) correctamente",
                    'numero_arete' => $_GET['numero_arete'],
                    'eliminados' => $count
                ]);
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