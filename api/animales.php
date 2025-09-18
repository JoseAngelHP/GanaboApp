<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$servername = "fdb1033.awardspace.net";
$username = "4685324_ganabo";
$password = "Angelito123";
$dbname = "4685324_ganabo";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Obtener método de la solicitud
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
       // Consultar animales (con filtro por número de arete si se proporciona)
    if (isset($_GET['numero_arete'])) {
        $numero_arete = $_GET['numero_arete'];
        
        // Usar consultas preparadas para seguridad
        $stmt = $conn->prepare("SELECT * FROM animales WHERE numero_arete = ?");
        $stmt->bind_param("s", $numero_arete); // "s" para string
        $stmt->execute();
        $result = $stmt->get_result();
    } else {
        $stmt = $conn->prepare("SELECT * FROM animales");
        $stmt->execute();
        $result = $stmt->get_result();
    }
    
    $animales = array();
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $animales[] = $row;
        }
    }
    echo json_encode($animales);
    break;
        
    case 'POST':
        // Insertar nuevo animal
        $data = json_decode(file_get_contents("php://input"), true);
        
        $sql = "INSERT INTO animales (numero_arete, raza, sexo, fecha_nacimiento, origen, padre, madre, foto_path) 
                VALUES ('".$data['numero_arete']."', '".$data['raza']."', '".$data['sexo']."', '".$data['fecha_nacimiento']."', 
                        '".$data['origen']."', '".$data['padre']."', '".$data['madre']."', '".$data['foto_path']."')";
        
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("message" => "Animal creado correctamente"));
        } else {
            echo json_encode(array("error" => "Error: " . $conn->error));
        }
        break;
        
    case 'PUT':
        // Actualizar animal
        $data = json_decode(file_get_contents("php://input"), true);
        $id = $data['id'];
        
        $sql = "UPDATE animales SET 
                numero_arete = '".$data['numero_arete']."',
                raza = '".$data['raza']."',
                sexo = '".$data['sexo']."',
                fecha_nacimiento = '".$data['fecha_nacimiento']."',
                origen = '".$data['origen']."',
                padre = '".$data['padre']."',
                madre = '".$data['madre']."',
                foto_path = '".$data['foto_path']."'
                WHERE id = $id";
        
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("message" => "Animal actualizado correctamente"));
        } else {
            echo json_encode(array("error" => "Error: " . $conn->error));
        }
        break;
        
    case 'DELETE':
        // Eliminar animal
        $data = json_decode(file_get_contents("php://input"), true);
        $id = $data['id'];
        
        $sql = "DELETE FROM animales WHERE id = $id";
        
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("message" => "Animal eliminado correctamente"));
        } else {
            echo json_encode(array("error" => "Error: " . $conn->error));
        }
        break;
}

$conn->close();
?>