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
    die("Connection failed: " . $conn->connect_error);
}

// Aqui obtenemos el método de la solicitud
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Aqui consultamos a los animales
        if (isset($_GET['numero_arete'])) {
            $numero_arete = $_GET['numero_arete'];
            
            $stmt = $conn->prepare("SELECT * FROM animales WHERE numero_arete = ?");
            $stmt->bind_param("s", $numero_arete); 
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
        // Aqui insertamos un nuevo animal
        $data = json_decode(file_get_contents("php://input"), true);
        
        $stmt = $conn->prepare("INSERT INTO animales (numero_arete, raza, sexo, fecha_nacimiento, origen, padre, madre, adquisicion, foto_path) 
                               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        
        $stmt->bind_param("sssssssss", 
            $data['numero_arete'],
            $data['raza'],
            $data['sexo'],
            $data['fecha_nacimiento'],
            $data['origen'],
            $data['padre'],
            $data['madre'],
            $data['adquisicion'],
            $data['foto_path']
        );
        
        if ($stmt->execute()) {
            echo json_encode(array("message" => "Animal creado correctamente"));
        } else {
            echo json_encode(array("error" => "Error: " . $stmt->error));
        }
        $stmt->close();
        break;
        
    case 'PUT':
        // Aqui actualizamos un animal
        $data = json_decode(file_get_contents("php://input"), true);
        
        $stmt = $conn->prepare("UPDATE animales SET 
                               numero_arete = ?,
                               raza = ?,
                               sexo = ?,
                               fecha_nacimiento = ?,
                               origen = ?,
                               padre = ?,
                               madre = ?,
                               adquisicion = ?,
                               foto_path = ?
                               WHERE id = ?");
        
        $stmt->bind_param("sssssssssi", 
            $data['numero_arete'],
            $data['raza'],
            $data['sexo'],
            $data['fecha_nacimiento'],
            $data['origen'],
            $data['padre'],
            $data['madre'],
            $data['adquisicion'],
            $data['foto_path'],
            $data['id']
        );
        
        if ($stmt->execute()) {
            echo json_encode(array("message" => "Animal actualizado correctamente"));
        } else {
            echo json_encode(array("error" => "Error: " . $stmt->error));
        }
        $stmt->close();
        break;
        
    case 'DELETE':
        // Aqui eliminamos el animal
        $data = json_decode(file_get_contents("php://input"), true);
        
        $stmt = $conn->prepare("DELETE FROM animales WHERE id = ?");
        $stmt->bind_param("i", $data['id']);
        
        if ($stmt->execute()) {
            echo json_encode(array("message" => "Animal eliminado correctamente"));
        } else {
            echo json_encode(array("error" => "Error: " . $stmt->error));
        }
        $stmt->close();
        break;
        
    default:
        echo json_encode(array("error" => "Método no permitido"));
        break;
}

$conn->close();
?>