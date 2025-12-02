const { Pool } = require('pg');

const DATABASE_URL = 'postgresql://immobilier_db_6phq_user:e21R1u9tThN2vUhSO8UB2F3ElNQU9Nc6@dpg-d4mv081r0fns73ahe9p0-a.frankfurt-postgres.render.com/immobilier_db_6phq';

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function debugRoleIssue() {
  try {
    console.log('🔍 Debugging role display issue...\n');
    
    // 1. Check what's actually in the database
    console.log('📊 Step 1: Checking database values');
    const dbResult = await pool.query('SELECT id, email, name, role FROM users ORDER BY id LIMIT 5');
    console.log('Database roles:');
    dbResult.rows.forEach(row => {
      console.log(`  - User ${row.id} (${row.email}): role = "${row.role}" (type: ${typeof row.role})`);
    });
    
    // 2. Test role update and see what gets returned
    console.log('\n📝 Step 2: Testing role update');
    const userId = dbResult.rows[0].id;
    console.log(`Updating user ${userId} to role "seller"...`);
    
    const updateResult = await pool.query(
      'UPDATE users SET role = $1 WHERE id = $2 RETURNING id, email, name, phone, avatar, role, created_at',
      ['seller', userId]
    );
    
    console.log('Update result:');
    console.log(JSON.stringify(updateResult.rows[0], null, 2));
    
    // 3. Check role constraints
    console.log('\n⚙️ Step 3: Checking role constraints');
    const constraintResult = await pool.query(`
      SELECT conname, pg_get_constraintdef(oid) as definition
      FROM pg_constraint
      WHERE conrelid = 'users'::regclass AND conname LIKE '%role%'
    `);
    
    if (constraintResult.rows.length > 0) {
      console.log('Role constraints:');
      constraintResult.rows.forEach(row => {
        console.log(`  ${row.conname}: ${row.definition}`);
      });
    } else {
      console.log('No role constraints found');
    }
    
    // 4. Test all allowed role values
    console.log('\n✅ Step 4: Testing all role values');
    const testRoles = ['visitor', 'buyer', 'seller'];
    for (const testRole of testRoles) {
      try {
        await pool.query('UPDATE users SET role = $1 WHERE id = $2', [testRole, userId]);
        console.log(`  ✓ "${testRole}" - OK`);
      } catch (e) {
        console.log(`  ✗ "${testRole}" - FAILED: ${e.message}`);
      }
    }
    
    // Test French values
    console.log('\nTesting French role values:');
    const frenchRoles = ['visiteur', 'acheteur', 'vendeur'];
    for (const testRole of frenchRoles) {
      try {
        await pool.query('UPDATE users SET role = $1 WHERE id = $2', [testRole, userId]);
        console.log(`  ✓ "${testRole}" - OK`);
      } catch (e) {
        console.log(`  ✗ "${testRole}" - FAILED: ${e.message}`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

debugRoleIssue();
