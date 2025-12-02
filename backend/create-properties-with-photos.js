const pool = require('./src/config/database');

const newProperties = [
  {
    title: 'Appartement S+3 vue mer La Marsa',
    description: 'Magnifique appartement de 3 chambres avec vue panoramique sur la mer. Situe dans une residence securisee a La Marsa. Proche de toutes commodites.',
    type: 'apartment',
    transaction_type: 'sale',
    price: 350000,
    surface: 140,
    rooms: 3,
    bathrooms: 2,
    address: 'La Marsa, Tunis',
    city: 'Tunis',
    latitude: 36.8785,
    longitude: 10.3270,
    amenities: ['parking', 'ascenseur', 'balcon', 'vue mer'],
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Villa moderne avec piscine Gammarth',
    description: 'Superbe villa contemporaine de 5 pieces avec piscine privee et jardin paysage. Quartier calme et residentiel a Gammarth. Finitions haut de gamme.',
    type: 'villa',
    transaction_type: 'sale',
    price: 1200000,
    surface: 350,
    rooms: 5,
    bathrooms: 4,
    address: 'Gammarth, Tunis',
    city: 'Tunis',
    latitude: 37.1167,
    longitude: 10.2833,
    amenities: ['piscine', 'jardin', 'garage', 'securite'],
    images: [
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Studio meuble centre ville Tunis',
    description: 'Studio moderne entierement meuble, ideal etudiant ou jeune professionnel. Situe en plein centre ville, proche transport et commerces.',
    type: 'studio',
    transaction_type: 'rent',
    price: 450,
    surface: 35,
    rooms: 1,
    bathrooms: 1,
    address: 'Centre Ville, Tunis',
    city: 'Tunis',
    latitude: 36.8065,
    longitude: 10.1815,
    amenities: ['meuble', 'climatisation', 'internet'],
    images: [
      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
      'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Maison traditionnelle renovee Hammamet',
    description: 'Charmante maison traditionnelle entierement renovee avec patio et terrasse. Architecture authentique avec confort moderne. Proche plage.',
    type: 'house',
    transaction_type: 'sale',
    price: 280000,
    surface: 180,
    rooms: 4,
    bathrooms: 2,
    address: 'Hammamet',
    city: 'Hammamet',
    latitude: 36.4000,
    longitude: 10.6167,
    amenities: ['terrasse', 'patio', 'parking'],
    images: [
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Appartement S+2 neuf Sousse',
    description: 'Appartement neuf jamais habite, 2 chambres dans residence standing avec piscine commune. Finitions luxueuses, proche centre Sousse.',
    type: 'apartment',
    transaction_type: 'sale',
    price: 220000,
    surface: 110,
    rooms: 2,
    bathrooms: 2,
    address: 'Sousse Centre',
    city: 'Sousse',
    latitude: 35.8256,
    longitude: 10.6367,
    amenities: ['piscine', 'ascenseur', 'parking', 'neuf'],
    images: [
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'https://images.unsplash.com/photo-1556912173-46c336c7fd55?w=800'
    ],
    owner_id: 1
  }
];

async function createProperties() {
  try {
    console.log('🏗️  Creating properties with photos...\n');
    
    let created = 0;
    
    for (const prop of newProperties) {
      const query = `
        INSERT INTO properties 
        (title, description, type, transaction_type, price, surface, rooms, bedrooms, bathrooms, 
         address, city, latitude, longitude, images, owner_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
        RETURNING id, title
      `;
      
      const values = [
        prop.title,
        prop.description,
        prop.type,
        prop.transaction_type,
        prop.price,
        prop.surface,
        prop.rooms,
        Math.max(1, prop.rooms - 1), // bedrooms = rooms - 1 (excluding living room)
        prop.bathrooms,
        prop.address,
        prop.city,
        prop.latitude,
        prop.longitude,
        prop.images,
        prop.owner_id
      ];
      
      const result = await pool.query(query, values);
      created++;
      
      console.log(`✅ ${created}/${newProperties.length} - Created: ${result.rows[0].title}`);
      console.log(`   📸 ${prop.images.length} photos added\n`);
    }
    
    console.log(`\n🎉 Done! Created ${created} properties with photos.`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

createProperties();
