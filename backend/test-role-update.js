const { Pool } = require('pg');

const DATABASE_URL = 'postgresql://immobilier_db_6phq_user:e21R1u9tThN2vUhSO8UB2F3ElNQU9Nc6@dpg-d4mv081r0fns73ahe9p0-a.frankfurt-postgres.render.com/immobilier_db_6phq';

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function testRoleUpdate() {
  try {
    console.log('🔍 Testing role update...\n');
    
    // Get a user
    const userResult = await pool.query('SELECT id, email, name, role FROM users ORDER BY id LIMIT 1');
    
    if (userResult.rows.length === 0) {
      console.log('❌ No user found');
      return;
    }
    
    const user = userResult.rows[0];
    console.log('👤 Current user:');
    console.log(`   ID: ${user.id}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Name: ${user.name}`);
    console.log(`   Role: ${user.role}\n`);
    
    // Try to update role to 'buyer'
    console.log('🔄 Attempting to update role to "buyer"...');
    
    try {
      const updateResult = await pool.query(
        'UPDATE users SET role = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING id, email, name, role',
        ['buyer', user.id]
      );
      
      console.log('✅ Update successful!');
      console.log('   New role:', updateResult.rows[0].role);
    } catch (updateError) {
      console.log('❌ Update failed!');
      console.log('   Error:', updateError.message);
      console.log('   Detail:', updateError.detail);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

testRoleUpdate();
