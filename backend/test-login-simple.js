const http = require('http');

const data = JSON.stringify({
  email: 'john@example.com',
  password: 'password123'
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = http.request(options, (res) => {
  let responseData = '';

  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    const response = JSON.parse(responseData);
    
    if (res.statusCode === 200) {
      console.log('✅ Login réussi!');
      console.log(`Token: ${response.token.substring(0, 50)}...`);
      console.log(`Utilisateur: ${response.user.name} (${response.user.email})`);
      console.log(`Rôle: ${response.user.role}`);
    } else {
      console.log('❌ Login échoué:', response.message);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Erreur de connexion:', error.message);
});

req.write(data);
req.end();
