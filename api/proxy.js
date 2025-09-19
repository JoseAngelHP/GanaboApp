export default async function handler(req, res) {
  // ¡AGREGA ESTOS HEADERS CORS!
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  // Manejar preflight requests (OPTIONS)
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  try {
    const { action } = req.query;
    
    // Validar que venga el action
    if (!action) {
      return res.status(400).json({ error: 'Parámetro action requerido' });
    }

    const targetUrl = `http://ganabovino.atwebpages.com/api/${action}.php`;

    const response = await fetch(targetUrl, {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
      },
      body: req.method !== 'GET' ? JSON.stringify(req.body) : undefined
    });

    const data = await response.text();
    res.status(response.status).send(data);

  } catch (error) {
    console.error('Error en proxy:', error);
    res.status(500).json({ error: 'Error en el proxy', message: error.message });
  }
}