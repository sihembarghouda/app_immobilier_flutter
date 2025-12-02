const https = require('https');
const data = JSON.stringify({
  email: 'user2@example.com',
  password: 'password123',
  name: 'User Two',
  phone: '+21620000001',
  role: 'visitor'
});

const options = {
  hostname: 'immobilier-backend.onrender.com',
  port: 443,
  path: '/api/auth/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = https.request(options, (res) => {
  let body = '';
  res.on('data', (chunk) => body += chunk);
  res.on('end', () => {
    console.log('Status:', res.statusCode);
    console.log('Body:', body);
  });
});

req.on('error', (e) => console.error('Error:', e));
req.write(data);
req.end();
