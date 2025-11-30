/**
 * Test du flux complet de token (Login → Save Token → Use Token)
 * Simule le comportement de l'application Flutter
 */

const axios = require('axios');

const API_URL = 'http://localhost:3000/api';

// Couleurs pour la console
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

async function testTokenFlow() {
  console.log('\n' + '='.repeat(60));
  log('🧪', 'TEST: Flux Complet du Token', colors.cyan);
  console.log('='.repeat(60) + '\n');

  let savedToken = null;
  let userId = null;

  // ============================================
  // ÉTAPE 1: LOGIN
  // ============================================
  try {
    log('1️⃣', 'Étape 1: Login...', colors.blue);
    
    const loginResponse = await axios.post(`${API_URL}/auth/login`, {
      email: 'john@example.com',
      password: 'password123',
    });

    savedToken = loginResponse.data.token;
    userId = loginResponse.data.user.id;

    log('✅', `Login réussi!`, colors.green);
    log('👤', `Utilisateur: ${loginResponse.data.user.name} (${loginResponse.data.user.email})`, colors.green);
    log('🔑', `Token reçu: ${savedToken.substring(0, 30)}...`, colors.green);
    log('💾', `Token sauvegardé dans la variable (simule SharedPreferences)`, colors.green);
    console.log('');

  } catch (error) {
    log('❌', `Login échoué: ${error.response?.data?.message || error.message}`, colors.red);
    process.exit(1);
  }

  // ============================================
  // ÉTAPE 2: UTILISER LE TOKEN POUR GET /me
  // ============================================
  try {
    log('2️⃣', 'Étape 2: Récupérer les infos utilisateur avec le token...', colors.blue);

    const meResponse = await axios.get(`${API_URL}/auth/me`, {
      headers: {
        'Authorization': `Bearer ${savedToken}`,
      },
    });

    log('✅', `GET /me réussi!`, colors.green);
    log('👤', `Utilisateur: ${meResponse.data.name} (ID: ${meResponse.data.id})`, colors.green);
    log('📧', `Email: ${meResponse.data.email}`, colors.green);
    log('🎭', `Rôle: ${meResponse.data.role}`, colors.green);
    console.log('');

  } catch (error) {
    log('❌', `GET /me échoué: ${error.response?.data?.message || error.message}`, colors.red);
    if (error.response?.status === 401) {
      log('⚠️', `ERREUR 401: Le token n'est pas accepté par le backend!`, colors.red);
    }
    process.exit(1);
  }

  // ============================================
  // ÉTAPE 3: UTILISER LE TOKEN POUR GET /properties
  // ============================================
  try {
    log('3️⃣', 'Étape 3: Récupérer les propriétés avec le token...', colors.blue);

    const propertiesResponse = await axios.get(`${API_URL}/properties`, {
      headers: {
        'Authorization': `Bearer ${savedToken}`,
      },
    });

    log('✅', `GET /properties réussi!`, colors.green);
    log('🏠', `${propertiesResponse.data.length} propriétés trouvées`, colors.green);
    
    if (propertiesResponse.data.length > 0) {
      const firstProperty = propertiesResponse.data[0];
      log('🏡', `Première propriété: ${firstProperty.title} - ${firstProperty.price}€`, colors.green);
    }
    console.log('');

  } catch (error) {
    log('❌', `GET /properties échoué: ${error.response?.data?.message || error.message}`, colors.red);
    if (error.response?.status === 401) {
      log('⚠️', `ERREUR 401: Le token n'est pas accepté par le backend!`, colors.red);
    }
    process.exit(1);
  }

  // ============================================
  // ÉTAPE 4: TESTER SANS TOKEN (doit échouer)
  // ============================================
  try {
    log('4️⃣', 'Étape 4: Tester GET /me SANS token (doit échouer)...', colors.blue);

    await axios.get(`${API_URL}/auth/me`);

    log('❌', `ERREUR: La requête sans token a réussi (elle devrait échouer!)`, colors.red);
    process.exit(1);

  } catch (error) {
    if (error.response?.status === 401) {
      log('✅', `Comportement correct: 401 sans token`, colors.green);
      log('📝', `Message: ${error.response?.data?.message}`, colors.green);
      console.log('');
    } else {
      log('❌', `Erreur inattendue: ${error.message}`, colors.red);
      process.exit(1);
    }
  }

  // ============================================
  // ÉTAPE 5: TESTER AVEC TOKEN INVALIDE (doit échouer)
  // ============================================
  try {
    log('5️⃣', 'Étape 5: Tester GET /me avec token INVALIDE (doit échouer)...', colors.blue);

    await axios.get(`${API_URL}/auth/me`, {
      headers: {
        'Authorization': 'Bearer invalid_token_xyz123',
      },
    });

    log('❌', `ERREUR: La requête avec token invalide a réussi (elle devrait échouer!)`, colors.red);
    process.exit(1);

  } catch (error) {
    if (error.response?.status === 401) {
      log('✅', `Comportement correct: 401 avec token invalide`, colors.green);
      log('📝', `Message: ${error.response?.data?.message}`, colors.green);
      console.log('');
    } else {
      log('❌', `Erreur inattendue: ${error.message}`, colors.red);
      process.exit(1);
    }
  }

  // ============================================
  // RÉSUMÉ
  // ============================================
  console.log('='.repeat(60));
  log('🎉', 'TOUS LES TESTS SONT PASSÉS!', colors.green);
  console.log('='.repeat(60));
  console.log('');
  log('✅', '1. Login fonctionne et retourne un token', colors.green);
  log('✅', '2. GET /me fonctionne avec le token', colors.green);
  log('✅', '3. GET /properties fonctionne avec le token', colors.green);
  log('✅', '4. Les requêtes sans token sont rejetées (401)', colors.green);
  log('✅', '5. Les requêtes avec token invalide sont rejetées (401)', colors.green);
  console.log('');
  log('🔍', 'CONCLUSION:', colors.cyan);
  log('📌', 'Le backend gère correctement les tokens JWT', colors.cyan);
  log('📌', 'Le problème "No token found" vient du frontend Flutter', colors.cyan);
  log('📌', 'Il faut vérifier que le token est bien chargé AVANT les requêtes', colors.cyan);
  console.log('');
}

// Exécuter le test
testTokenFlow().catch(error => {
  console.error('\n❌ Test interrompu:', error.message);
  process.exit(1);
});
