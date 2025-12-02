const pool = require('./src/config/database');

// Property photos mapping
const propertyPhotos = {
  'Appartement S+3 vue mer': [
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=800',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'
  ],
  'Villa moderne avec piscine': [
    'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800'
  ],
  'Studio meuble centre ville': [
    'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
    'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800'
  ],
  'Maison traditionnelle renovee': [
    'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
    'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
    'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800'
  ],
  'Appartement S+2 neuf': [
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
    'https://images.unsplash.com/photo-1556912173-46c336c7fd55?w=800'
  ],
  'Villa pieds dans eau': [
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
    'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800'
  ],
  'Studio etudiant': [
    'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
    'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800'
  ],
  'Maison avec jardin': [
    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
    'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
    'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800'
  ]
};

async function updatePhotos() {
  try {
    console.log('📋 Getting properties...\n');
    
    const result = await pool.query('SELECT id, title, images FROM properties ORDER BY id');
    const properties = result.rows;
    
    console.log(`Found ${properties.length} properties\n`);
    
    let updated = 0;
    
    for (const property of properties) {
      // Find matching photos by checking if property title starts with the photo key
      for (const [titleKey, photos] of Object.entries(propertyPhotos)) {
        if (property.title.includes(titleKey.split(' ')[0])) {
          console.log(`📸 Updating: ${property.title}`);
          
          // Update the property with photos (images is already an array type in PostgreSQL)
          await pool.query(
            'UPDATE properties SET images = $1 WHERE id = $2',
            [photos, property.id]
          );
          
          console.log(`✅ Added ${photos.length} photos`);
          console.log(`   ${photos[0]}\n`);
          updated++;
          break;
        }
      }
    }
    
    console.log(`\n🎉 Done! Updated ${updated} properties with photos.`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

updatePhotos();
