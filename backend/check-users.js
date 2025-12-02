const pool = require('./src/config/database');

async function checkUsers() {
  try {
    const result = await pool.query('SELECT id, name, email FROM users ORDER BY id LIMIT 5');
    console.log('Users in database:');
    console.log(JSON.stringify(result.rows, null, 2));
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkUsers();
