// src/database/add_role_column.js
require('dotenv').config();
const { Client } = require('pg');

const addRoleColumn = async () => {
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'immobilier_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
  });

  try {
    await client.connect();
    console.log('✅ Connected to database');

    // Add role column to users table
    await client.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'visitor' 
      CHECK (role IN ('buyer', 'seller', 'visitor'))
    `);
    console.log('✅ Added role column to users table');

    // Update existing users to have default role
    await client.query(`
      UPDATE users 
      SET role = 'visitor' 
      WHERE role IS NULL
    `);
    console.log('✅ Updated existing users with default role');

    console.log('\n🎉 Database update completed successfully!');
    await client.end();
    process.exit(0);
  } catch (error) {
    console.error('❌ Update failed:', error);
    process.exit(1);
  }
};

addRoleColumn();
