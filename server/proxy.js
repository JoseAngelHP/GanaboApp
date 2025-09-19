export default async function handler(req, res) {
  // Solo permitir el dominio PRINCIPAL
  res.setHeader('Access-Control-Allow-Origin', 'https://ganaboapp.vercel.app');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Max-Age', '86400');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  try {
    const { action } = req.query;
    
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
    res.status(500).json({ error: error.message });
  }
}