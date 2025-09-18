export default async function handler(req, res) {
  try {
    const { action } = req.query;
    const targetUrl = `http://ganabovino.atwebpages.com/api/${action}.php`; // ← BACKTICKS aquí

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
    res.status(500).json({ error: 'Error en el proxy' });
  }
}