const axios = require('axios');

const API_URL = 'https://immobilier-backend.onrender.com/api';

async function testCompleteFlow() {
  try {
    console.log('🧪 Testing complete role change flow\n');
    
    // 1. Register a test user
    console.log('1️⃣ Creating test user...');
    try {
      const registerResponse = await axios.post(`${API_URL}/auth/register`, {
        name: 'Test User Role',
        email: 'testrole@example.com',
        password: 'test123456',
        phone: '+216 12345678',
        role: 'visitor'
      });
      console.log('✅ Test user created');
    } catch (e) {
      if (e.response?.data?.message?.includes('existe déjà') || e.response?.data?.message?.includes('déjà utilisé')) {
        console.log('ℹ️  Test user already exists, continuing...');
      } else {
        throw e;
      }
    }
    
    // 2. Login
    console.log('\n2️⃣ Login...');
    const loginResponse = await axios.post(`${API_URL}/auth/login`, {
      email: 'testrole@example.com',
      password: 'test123456'
    });
    
    const token = loginResponse.data.data.token;
    const user = loginResponse.data.data.user;
    
    console.log('✅ Logged in successfully');
    console.log(`   User: ${user.name}`);
    console.log(`   Current role: ${user.role}`);
    console.log(`   Token: ${token.substring(0, 20)}...\n`);
    
    // 3. Update role to seller
    console.log('3️⃣ Updating role to "seller"...');
    const updateResponse = await axios.put(
      `${API_URL}/auth/profile`,
      {
        name: user.name,
        phone: user.phone || '',
        role: 'seller'
      },
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    console.log('✅ Update response received');
    console.log('   Response data:', JSON.stringify(updateResponse.data, null, 2));
    
    const updatedUser = updateResponse.data.data;
    console.log(`   Updated user role: ${updatedUser.role}`);
    
    // 3. Login again to verify
    console.log('\n4️⃣ Login again to verify role persisted...');
    const loginResponse2 = await axios.post(`${API_URL}/auth/login`, {
      email: 'testrole@example.com',
      password: 'test123456'
    });
    
    const user2 = loginResponse2.data.data.user;
    console.log('✅ Logged in again');
    console.log(`   Role from fresh login: ${user2.role}`);
    
    if (user2.role === 'seller') {
      console.log('\n🎉 SUCCESS! Role change is working correctly!');
    } else {
      console.log(`\n❌ PROBLEM! Role should be "seller" but got "${user2.role}"`);
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error.response?.data || error.message);
  }
}

testCompleteFlow();
