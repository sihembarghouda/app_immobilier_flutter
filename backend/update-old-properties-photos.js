const { Pool } = require('pg');

// Render production database URL
const DATABASE_URL = 'postgresql://immobilier_db_6phq_user:e21R1u9tThN2vUhSO8UB2F3ElNQU9Nc6@dpg-d4mv081r0fns73ahe9p0-a.frankfurt-postgres.render.com/immobilier_db_6phq';

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// Photos pour différents types de propriétés
const photosByType = {
  apartment: [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'
  ],
  villa: [
    'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800'
  ],
  studio: [
    'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
    'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800',
    'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800'
  ],
  house: [
    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
    'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
    'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800'
  ]
};

async function updateOldProperties() {
  try {
    console.log('🌐 Connecting to Render production database...\n');
    
    await pool.query('SELECT NOW()');
    console.log('✅ Connected to production database\n');
    
    // Get properties without photos (IDs 1-10)
    const result = await pool.query(`
      SELECT id, title, type 
      FROM properties 
      WHERE id <= 10 
      ORDER BY id
    `);
    
    console.log(`📋 Found ${result.rows.length} properties to update\n`);
    
    let updated = 0;
    
    for (const property of result.rows) {
      // Get photos based on type
      let photos = photosByType[property.type];
      
      // Fallback to apartment photos if type not found
      if (!photos) {
        photos = photosByType.apartment;
      }
      
      // Update property with photos
      await pool.query(
        'UPDATE properties SET images = $1 WHERE id = $2',
        [photos, property.id]
      );
      
      updated++;
      console.log(`✅ ${updated}/${result.rows.length} - Updated: ${property.title}`);
      console.log(`   📸 Added ${photos.length} photos (type: ${property.type})\n`);
    }
    
    console.log(`\n🎉 Done! Updated ${updated} properties with photos.`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

updateOldProperties();
