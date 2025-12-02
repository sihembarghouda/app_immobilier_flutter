const https = require('https');
const loginData = JSON.stringify({ email: 'demo@immobilier.tn', password: 'demo123' });

function request(options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body }));
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

(async ()=>{
  try {
    const loginOpts = {
      hostname: 'immobilier-backend.onrender.com', port: 443, path: '/api/auth/login', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': loginData.length }
    };
    const loginRes = await request(loginOpts, loginData);
    console.log('Login:', loginRes.status, loginRes.body);
    const parsed = JSON.parse(loginRes.body);
    if (!parsed.success) return console.error('Login failed');
    const token = parsed.data.token;

    const property = JSON.stringify({
      title: 'Test Property', description: 'Nice place', type: 'apartment', transaction_type: 'sale',
      price: 100000.00, surface: 120.5, rooms: 4, bedrooms: 3, bathrooms: 2,
      address: 'Rue de Test', city: 'Tunis', latitude: 36.8065, longitude: 10.1815
    });

    const propOpts = {
      hostname: 'immobilier-backend.onrender.com', port: 443, path: '/api/properties', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': property.length, 'Authorization': 'Bearer ' + token }
    };

    const propRes = await request(propOpts, property);
    console.log('Create property:', propRes.status, propRes.body);
  } catch (e) {
    console.error('Error:', e);
  }
})();
