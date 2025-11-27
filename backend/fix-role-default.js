const {Pool} = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'immobilier_db'
});

pool.query("ALTER TABLE users ALTER COLUMN role SET DEFAULT 'visiteur'")
  .then(() => {
    console.log('✅ Default changé de visitor → visiteur');
    return pool.end();
  })
  .catch(err => {
    console.error('❌ Erreur:', err.message);
    pool.end();
  });
