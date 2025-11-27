#!/usr/bin/env node
/**
 * 🔍 Script de Diagnostic Complet
 * 
 * Ce script teste tous les aspects de l'authentification et identifie
 * exactement où se trouve le problème 401.
 */

const http = require('http');

const API_BASE = 'http://localhost:3000/api';
let authToken = null;
let userId = null;

// Couleurs pour les logs
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(emoji, message, color = colors.reset) {
  console.log(`${color}${emoji} ${message}${colors.reset}`);
}

function makeRequest(method, path, data = null, useAuth = false) {
  return new Promise((resolve, reject) => {
    const url = new URL(API_BASE + path);
    
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    if (useAuth && authToken) {
      options.headers['Authorization'] = `Bearer ${authToken}`;
      log('🔑', `Adding auth header: Bearer ${authToken.substring(0, 20)}...`, colors.cyan);
    }

    const req = http.request(options, (res) => {
      let body = '';
      
      res.on('data', (chunk) => {
        body += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsed = JSON.parse(body);
          resolve({ status: res.statusCode, data: parsed, headers: res.headers });
        } catch (e) {
          resolve({ status: res.statusCode, data: body, headers: res.headers });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

async function testHealth() {
  log('🏥', '=== TEST 1: Health Check ===', colors.blue);
  
  try {
    const response = await makeRequest('GET', '/../health');
    
    if (response.status === 200) {
      log('✅', `Server is UP - ${response.data.message}`, colors.green);
      return true;
    } else {
      log('❌', `Server responded with ${response.status}`, colors.red);
      return false;
    }
  } catch (error) {
    log('❌', `Server is DOWN: ${error.message}`, colors.red);
    log('💡', 'Run: cd backend && npm run dev', colors.yellow);
    return false;
  }
}

async function testRegister() {
  log('📝', '=== TEST 2: Register New User ===', colors.blue);
  
  const testUser = {
    email: `test_${Date.now()}@example.com`,
    password: 'test123456',
    name: 'Test User Diagnostic',
    phone: '1234567890'
  };

  log('📤', `Registering: ${testUser.email}`, colors.cyan);

  try {
    const response = await makeRequest('POST', '/auth/register', testUser);
    
    if (response.status === 201) {
      log('✅', 'Registration successful', colors.green);
      
      // Handle nested data structure (data.data.token and data.data.user)
      const responseData = response.data.data || response.data;
      
      if (responseData.user && responseData.token) {
        log('📋', `User ID: ${responseData.user.id}`, colors.cyan);
        log('🔑', `Token received: ${responseData.token.substring(0, 30)}...`, colors.cyan);
        
        authToken = responseData.token;
        userId = responseData.user.id;
        
        return true;
      } else {
        log('❌', 'Invalid response structure', colors.red);
        log('📋', JSON.stringify(response.data, null, 2), colors.red);
        return false;
      }
    } else {
      log('❌', `Registration failed: ${response.status}`, colors.red);
      log('📋', JSON.stringify(response.data, null, 2), colors.red);
      return false;
    }
  } catch (error) {
    log('❌', `Registration error: ${error.message}`, colors.red);
    return false;
  }
}

async function testLogin() {
  log('🔐', '=== TEST 3: Login Existing User ===', colors.blue);
  
  // Try with a test user that we know exists, or use default credentials
  const credentials = {
    email: 'test@example.com',
    password: 'test123456'
  };

  log('📤', `Logging in: ${credentials.email}`, colors.cyan);
  log('💡', `If login fails, a new account will be created via register`, colors.yellow);

  try {
    const response = await makeRequest('POST', '/auth/login', credentials);
    
    if (response.status === 200) {
      log('✅', 'Login successful', colors.green);
      
      // Handle nested data structure
      const responseData = response.data.data || response.data;
      
      if (responseData.user && responseData.token) {
        log('📋', `User: ${responseData.user.name}`, colors.cyan);
        log('🔑', `Token received: ${responseData.token.substring(0, 30)}...`, colors.cyan);
        
        authToken = responseData.token;
        userId = responseData.user.id;
        
        return true;
      } else {
        log('❌', 'Invalid response structure', colors.red);
        log('📋', JSON.stringify(response.data, null, 2), colors.red);
        return false;
      }
    } else {
      log('❌', `Login failed: ${response.status}`, colors.red);
      log('📋', JSON.stringify(response.data, null, 2), colors.red);
      return false;
    }
  } catch (error) {
    log('❌', `Login error: ${error.message}`, colors.red);
    return false;
  }
}

async function testGetCurrentUser() {
  log('👤', '=== TEST 4: Get Current User (Protected) ===', colors.blue);
  
  log('📤', 'Requesting /auth/me with token...', colors.cyan);

  try {
    const response = await makeRequest('GET', '/auth/me', null, true);
    
    if (response.status === 200) {
      log('✅', 'Get current user successful', colors.green);
      
      const userData = response.data.data || response.data;
      const userName = userData.name || 'Unknown';
      const userEmail = userData.email || 'unknown@example.com';
      log('📋', `User: ${userName} (${userEmail})`, colors.cyan);
      return true;
    } else {
      log('❌', `Get current user failed: ${response.status}`, colors.red);
      log('📋', JSON.stringify(response.data, null, 2), colors.red);
      
      if (response.status === 401) {
        log('🔍', 'DIAGNOSTIC: Token is being REJECTED by backend', colors.yellow);
        log('🔍', 'Possible causes:', colors.yellow);
        log('  1️⃣', 'JWT_SECRET mismatch between token generation and verification');
        log('  2️⃣', 'Token format incorrect (check "Bearer " prefix)');
        log('  3️⃣', 'Middleware not attaching req.user correctly');
        log('  4️⃣', '.env not loaded (dotenv.config() missing)');
      }
      
      return false;
    }
  } catch (error) {
    log('❌', `Get current user error: ${error.message}`, colors.red);
    return false;
  }
}

async function testUpdateProfile() {
  log('✏️', '=== TEST 5: Update Profile (Protected) ===', colors.blue);
  
  const updates = {
    name: 'Test User Updated',
    phone: '9876543210'
  };

  log('📤', 'Updating profile with token...', colors.cyan);

  try {
    const response = await makeRequest('PUT', '/auth/profile', updates, true);
    
    if (response.status === 200) {
      log('✅', 'Update profile successful', colors.green);
      
      const userData = response.data.user || response.data.data || response.data;
      const userName = userData.name || userData.email || 'Unknown';
      log('📋', `Updated user: ${userName}`, colors.cyan);
      return true;
    } else {
      log('❌', `Update profile failed: ${response.status}`, colors.red);
      log('📋', JSON.stringify(response.data, null, 2), colors.red);
      return false;
    }
  } catch (error) {
    log('❌', `Update profile error: ${error.message}`, colors.red);
    return false;
  }
}

async function testGetFavorites() {
  log('⭐', '=== TEST 6: Get Favorites (Protected) ===', colors.blue);
  
  log('📤', 'Requesting favorites with token...', colors.cyan);

  try {
    const response = await makeRequest('GET', '/favorites', null, true);
    
    if (response.status === 200) {
      log('✅', 'Get favorites successful', colors.green);
      log('📋', `Favorites count: ${response.data.count || response.data.data?.length || 0}`, colors.cyan);
      return true;
    } else {
      log('❌', `Get favorites failed: ${response.status}`, colors.red);
      log('📋', JSON.stringify(response.data, null, 2), colors.red);
      return false;
    }
  } catch (error) {
    log('❌', `Get favorites error: ${error.message}`, colors.red);
    return false;
  }
}

async function testGetConversations() {
  log('💬', '=== TEST 7: Get Conversations (Protected) ===', colors.blue);
  
  log('📤', 'Requesting conversations with token...', colors.cyan);

  try {
    const response = await makeRequest('GET', '/messages/conversations', null, true);
    
    if (response.status === 200) {
      log('✅', 'Get conversations successful', colors.green);
      log('📋', `Conversations count: ${response.data.count || response.data.data?.length || 0}`, colors.cyan);
      return true;
    } else {
      log('❌', `Get conversations failed: ${response.status}`, colors.red);
      log('📋', JSON.stringify(response.data, null, 2), colors.red);
      return false;
    }
  } catch (error) {
    log('❌', `Get conversations error: ${error.message}`, colors.red);
    return false;
  }
}

async function testTokenStructure() {
  log('🔬', '=== TEST 8: Analyze Token Structure ===', colors.blue);
  
  if (!authToken) {
    log('❌', 'No token available to analyze', colors.red);
    return false;
  }

  const parts = authToken.split('.');
  
  if (parts.length !== 3) {
    log('❌', `Invalid JWT structure: ${parts.length} parts (should be 3)`, colors.red);
    return false;
  }

  log('✅', 'JWT has 3 parts (header.payload.signature)', colors.green);

  try {
    // Decode header
    const header = JSON.parse(Buffer.from(parts[0], 'base64').toString());
    log('📋', `Header: ${JSON.stringify(header)}`, colors.cyan);

    // Decode payload
    const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
    log('📋', `Payload: ${JSON.stringify(payload)}`, colors.cyan);
    
    // Check expiration
    if (payload.exp) {
      const expiresAt = new Date(payload.exp * 1000);
      const now = new Date();
      
      if (expiresAt > now) {
        log('✅', `Token expires at: ${expiresAt.toISOString()}`, colors.green);
      } else {
        log('❌', `Token EXPIRED at: ${expiresAt.toISOString()}`, colors.red);
      }
    }

    return true;
  } catch (error) {
    log('❌', `Token decode error: ${error.message}`, colors.red);
    return false;
  }
}

async function runAllTests() {
  console.log('\n' + '='.repeat(60));
  log('🚀', 'DIAGNOSTIC COMPLET - AUTHENTIFICATION JWT', colors.blue);
  console.log('='.repeat(60) + '\n');

  const results = [];

  // Test 1: Health
  results.push({ test: 'Health Check', passed: await testHealth() });
  console.log('\n');

  if (!results[0].passed) {
    log('⛔', 'Server is not running. Please start it first.', colors.red);
    process.exit(1);
  }

  // Test 2: Register (or Login if register fails)
  results.push({ test: 'Register', passed: await testRegister() });
  console.log('\n');

  if (!results[1].passed) {
    log('⚠️', 'Register failed, trying login instead...', colors.yellow);
    results.push({ test: 'Login', passed: await testLogin() });
    console.log('\n');
  }

  if (!authToken) {
    log('⛔', 'Cannot continue: No token obtained', colors.red);
    process.exit(1);
  }

  // Test 3: Token structure
  results.push({ test: 'Token Structure', passed: await testTokenStructure() });
  console.log('\n');

  // Test 4: Get current user
  results.push({ test: 'Get Current User', passed: await testGetCurrentUser() });
  console.log('\n');

  // Test 5: Update profile
  results.push({ test: 'Update Profile', passed: await testUpdateProfile() });
  console.log('\n');

  // Test 6: Get favorites
  results.push({ test: 'Get Favorites', passed: await testGetFavorites() });
  console.log('\n');

  // Test 7: Get conversations
  results.push({ test: 'Get Conversations', passed: await testGetConversations() });
  console.log('\n');

  // Summary
  console.log('='.repeat(60));
  log('📊', 'RÉSULTATS DU DIAGNOSTIC', colors.blue);
  console.log('='.repeat(60));

  results.forEach((result, index) => {
    const status = result.passed ? '✅ PASS' : '❌ FAIL';
    const color = result.passed ? colors.green : colors.red;
    log(result.passed ? '✅' : '❌', `${index + 1}. ${result.test.padEnd(25)} ${status}`, color);
  });

  const passedCount = results.filter(r => r.passed).length;
  const totalCount = results.length;
  const passRate = ((passedCount / totalCount) * 100).toFixed(0);

  console.log('='.repeat(60));
  log('📈', `Score: ${passedCount}/${totalCount} (${passRate}%)`, passRate === '100' ? colors.green : colors.yellow);
  console.log('='.repeat(60) + '\n');

  if (passRate !== '100') {
    log('🔧', 'RECOMMANDATIONS:', colors.yellow);
    
    const failedTests = results.filter(r => !r.passed);
    
    if (failedTests.some(t => t.test.includes('Current User') || t.test.includes('Profile') || t.test.includes('Favorites'))) {
      log('1️⃣', 'Vérifier que JWT_SECRET est identique entre génération et vérification', colors.yellow);
      log('2️⃣', 'Vérifier que dotenv.config() est appelé au début de server.js', colors.yellow);
      log('3️⃣', 'Vérifier que le middleware auth attache bien req.user', colors.yellow);
      log('4️⃣', 'Vérifier les logs backend pendant les requêtes', colors.yellow);
    }
  } else {
    log('🎉', 'TOUT FONCTIONNE PARFAITEMENT !', colors.green);
  }

  console.log('\n');
}

// Run diagnostic
runAllTests().catch(error => {
  log('❌', `Fatal error: ${error.message}`, colors.red);
  console.error(error);
  process.exit(1);
});
