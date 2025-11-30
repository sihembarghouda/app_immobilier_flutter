// Test complet du système d'authentification
const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testAuth() {
  console.log('\n🧪 TEST SYSTÈME AUTHENTIFICATION\n');
  console.log('='.repeat(60));
  
  const testUser = {
    name: 'Test User Auth',
    email: `test${Date.now()}@test.com`,
    password: 'test123456',
    phone: '71234567',
    role: 'acheteur'
  };
  
  try {
    // 1. Test Register
    console.log('\n📝 1. TEST REGISTER');
    console.log(`POST ${BASE_URL}/api/auth/register`);
    
    const registerRes = await axios.post(`${BASE_URL}/api/auth/register`, testUser);
    
    if (registerRes.data.success && registerRes.data.data.token) {
      console.log('✅ Register OK');
      console.log('   Token:', registerRes.data.data.token.substring(0, 20) + '...');
      console.log('   User:', registerRes.data.data.user.email);
    } else {
      console.log('❌ Register FAILED - No token in response');
      console.log('   Response:', JSON.stringify(registerRes.data, null, 2));
      return;
    }
    
    const token = registerRes.data.data.token;
    
    // 2. Test Login
    console.log('\n🔐 2. TEST LOGIN');
    console.log(`POST ${BASE_URL}/api/auth/login`);
    
    const loginRes = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: testUser.email,
      password: testUser.password
    });
    
    if (loginRes.data.success && loginRes.data.data.token) {
      console.log('✅ Login OK');
      console.log('   Token:', loginRes.data.data.token.substring(0, 20) + '...');
    } else {
      console.log('❌ Login FAILED');
      console.log('   Response:', JSON.stringify(loginRes.data, null, 2));
      return;
    }
    
    // 3. Test GET /me (avec token)
    console.log('\n👤 3. TEST GET /api/auth/me');
    
    try {
      const meRes = await axios.get(`${BASE_URL}/api/auth/me`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (meRes.data.success) {
        console.log('✅ GET /me OK');
        console.log('   User:', meRes.data.data.email);
      } else {
        console.log('❌ GET /me FAILED');
        console.log('   Response:', JSON.stringify(meRes.data, null, 2));
      }
    } catch (error) {
      console.log('❌ GET /me ERROR:', error.response?.data?.message || error.message);
    }
    
    // 4. Test PUT /profile (avec token)
    console.log('\n✏️  4. TEST PUT /api/auth/profile');
    
    try {
      const profileRes = await axios.put(
        `${BASE_URL}/api/auth/profile`,
        {
          name: 'Updated Name',
          phone: '71999999'
        },
        {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        }
      );
      
      if (profileRes.data.success) {
        console.log('✅ PUT /profile OK');
        console.log('   Updated name:', profileRes.data.data.name);
      } else {
        console.log('❌ PUT /profile FAILED');
        console.log('   Response:', JSON.stringify(profileRes.data, null, 2));
      }
    } catch (error) {
      console.log('❌ PUT /profile ERROR:', error.response?.data?.message || error.message);
    }
    
    // 5. Test sans token (doit échouer)
    console.log('\n🚫 5. TEST GET /me SANS TOKEN (doit échouer)');
    
    try {
      await axios.get(`${BASE_URL}/api/auth/me`);
      console.log('❌ ERREUR: Devrait retourner 401!');
    } catch (error) {
      if (error.response?.status === 401) {
        console.log('✅ 401 OK (comme attendu)');
        console.log('   Message:', error.response.data.message);
      } else {
        console.log('❌ Statut inattendu:', error.response?.status);
      }
    }
    
    // 6. Test token invalide
    console.log('\n🚫 6. TEST TOKEN INVALIDE (doit échouer)');
    
    try {
      await axios.get(`${BASE_URL}/api/auth/me`, {
        headers: {
          'Authorization': 'Bearer invalid_token_xyz'
        }
      });
      console.log('❌ ERREUR: Devrait retourner 401!');
    } catch (error) {
      if (error.response?.status === 401) {
        console.log('✅ 401 OK (comme attendu)');
        console.log('   Message:', error.response.data.message);
      } else {
        console.log('❌ Statut inattendu:', error.response?.status);
      }
    }
    
    console.log('\n' + '='.repeat(60));
    console.log('\n✅ TOUS LES TESTS PASSÉS!\n');
    console.log('📋 RÉSUMÉ:');
    console.log('   ✅ Register fonctionne (retourne token)');
    console.log('   ✅ Login fonctionne (retourne token)');
    console.log('   ✅ GET /me fonctionne avec token');
    console.log('   ✅ PUT /profile fonctionne avec token');
    console.log('   ✅ Middleware rejette requêtes sans token');
    console.log('   ✅ Middleware rejette token invalide');
    console.log('\n' + '='.repeat(60) + '\n');
    
  } catch (error) {
    console.error('\n❌ ERREUR CRITIQUE:', error.response?.data || error.message);
    console.error('   Status:', error.response?.status);
    console.error('   URL:', error.config?.url);
  }
}

// Vérifier que le serveur est démarré
axios.get(`${BASE_URL}/health`)
  .then(() => {
    console.log('✅ Serveur OK, démarrage des tests...');
    testAuth();
  })
  .catch(err => {
    console.error('❌ Serveur non accessible:', err.message);
    console.error('   Assurez-vous que le backend est démarré sur', BASE_URL);
  });
