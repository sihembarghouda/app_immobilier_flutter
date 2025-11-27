// Test rapide d'authentification
const http = require('http');

async function testAuth() {
  console.log('🧪 Test Authentification Simple\n');
  
  // Step 1: Register
  console.log('📝 Step 1: Register...');
  const registerData = JSON.stringify({
    email: `test_${Date.now()}@example.com`,
    password: 'test123456',
    name: 'Test User',
    phone: '1234567890'
  });
  
  const registerOptions = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/auth/register',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': registerData.length
    }
  };
  
  const registerResponse = await new Promise((resolve, reject) => {
    const req = http.request(registerOptions, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.on('error', reject);
    req.write(registerData);
    req.end();
  });
  
  console.log(`Status: ${registerResponse.status}`);
  console.log('Response:', JSON.stringify(registerResponse.data, null, 2));
  
  if (registerResponse.status !== 201) {
    console.log('❌ Register failed!');
    return;
  }
  
  const token = registerResponse.data.data?.token || registerResponse.data.token;
  if (!token) {
    console.log('❌ No token received!');
    return;
  }
  
  console.log(`✅ Token: ${token.substring(0, 50)}...\n`);
  
  // Step 2: Get Current User
  console.log('👤 Step 2: Get Current User...');
  const meOptions = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/auth/me',
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  };
  
  const meResponse = await new Promise((resolve, reject) => {
    const req = http.request(meOptions, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.on('error', reject);
    req.end();
  });
  
  console.log(`Status: ${meResponse.status}`);
  console.log('Response:', JSON.stringify(meResponse.data, null, 2));
  
  if (meResponse.status === 200) {
    console.log('✅ /auth/me fonctionne!');
  } else {
    console.log('❌ /auth/me échoue!');
    console.log('\n💡 Vérifier les logs backend pour voir exactement le problème');
  }
  
  // Step 3: Get Favorites
  console.log('\n⭐ Step 3: Get Favorites...');
  const favOptions = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/favorites',
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  };
  
  const favResponse = await new Promise((resolve, reject) => {
    const req = http.request(favOptions, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.on('error', reject);
    req.end();
  });
  
  console.log(`Status: ${favResponse.status}`);
  console.log('Response:', JSON.stringify(favResponse.data, null, 2));
  
  if (favResponse.status === 200) {
    console.log('✅ /favorites fonctionne!');
  } else {
    console.log('❌ /favorites échoue!');
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('📊 RÉSUMÉ');
  console.log('='.repeat(60));
  console.log(`Register: ${registerResponse.status === 201 ? '✅' : '❌'}`);
  console.log(`Get Me: ${meResponse.status === 200 ? '✅' : '❌'}`);
  console.log(`Favorites: ${favResponse.status === 200 ? '✅' : '❌'}`);
  console.log('\n💡 Vérifier les logs du serveur backend maintenant!');
}

testAuth().catch(console.error);
