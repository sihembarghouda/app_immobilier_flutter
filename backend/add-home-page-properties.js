const { Pool } = require('pg');

// Render production database URL
const DATABASE_URL = 'postgresql://immobilier_db_6phq_user:e21R1u9tThN2vUhSO8UB2F3ElNQU9Nc6@dpg-d4mv081r0fns73ahe9p0-a.frankfurt-postgres.render.com/immobilier_db_6phq';

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// Nouvelles annonces concentrées à Tunis centre (rayon proche pour page d'accueil)
const homePageProperties = [
  {
    title: 'Appartement S+2 Lafayette',
    description: 'Bel appartement de 2 chambres au coeur de Tunis, quartier Lafayette. Proche de l Avenue Habib Bourguiba, transport et commerces. Ideal pour jeune couple.',
    type: 'apartment',
    transaction_type: 'rent',
    price: 650,
    surface: 85,
    rooms: 2,
    bathrooms: 1,
    address: 'Avenue de Paris, Lafayette',
    city: 'Tunis',
    latitude: 36.8000,
    longitude: 10.1800,
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Villa spacieuse Menzah 6',
    description: 'Villa familiale de standing avec jardin et parking. 4 chambres, salon spacieux, cuisine moderne. Quartier calme et securise a Menzah 6.',
    type: 'villa',
    transaction_type: 'sale',
    price: 580000,
    surface: 240,
    rooms: 4,
    bathrooms: 3,
    address: 'Menzah 6',
    city: 'Tunis',
    latitude: 36.8400,
    longitude: 10.1750,
    images: [
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Studio moderne Montplaisir',
    description: 'Studio tout confort dans residence recente a Montplaisir. Meuble, climatise, cuisine equipee. Ideal celibataire ou etudiant.',
    type: 'studio',
    transaction_type: 'rent',
    price: 420,
    surface: 32,
    rooms: 1,
    bathrooms: 1,
    address: 'Rue de Marseille, Montplaisir',
    city: 'Tunis',
    latitude: 36.8150,
    longitude: 10.1950,
    images: [
      'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Appartement S+3 Manar 2',
    description: 'Grand appartement lumineux de 3 chambres au Manar 2. Balcon, parking prive, proche ecoles et commerces. Residence securisee avec ascenseur.',
    type: 'apartment',
    transaction_type: 'sale',
    price: 295000,
    surface: 130,
    rooms: 3,
    bathrooms: 2,
    address: 'Cite El Manar 2',
    city: 'Tunis',
    latitude: 36.8350,
    longitude: 10.1900,
    images: [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
      'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Maison traditionnelle Medina',
    description: 'Charmante maison traditionnelle dans la Medina de Tunis. Architecture authentique, patio central, terrasse avec vue. Ideale pour projet touristique.',
    type: 'house',
    transaction_type: 'sale',
    price: 420000,
    surface: 180,
    rooms: 4,
    bathrooms: 2,
    address: 'Medina de Tunis',
    city: 'Tunis',
    latitude: 36.8100,
    longitude: 10.1700,
    images: [
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Appartement neuf El Menzah 5',
    description: 'Appartement flambant neuf jamais habite, finitions luxueuses. 2 chambres, cuisine equipee, balcon. Residence standing avec piscine.',
    type: 'apartment',
    transaction_type: 'sale',
    price: 310000,
    surface: 110,
    rooms: 2,
    bathrooms: 2,
    address: 'El Menzah 5',
    city: 'Tunis',
    latitude: 36.8380,
    longitude: 10.1800,
    images: [
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'https://images.unsplash.com/photo-1556912173-46c336c7fd55?w=800',
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Villa contemporaine Berges du Lac',
    description: 'Superbe villa moderne aux Berges du Lac. Architecture contemporaine, piscine, jardin paysage. 5 chambres, finitions haut de gamme.',
    type: 'villa',
    transaction_type: 'sale',
    price: 1350000,
    surface: 380,
    rooms: 5,
    bathrooms: 4,
    address: 'Les Berges du Lac 1',
    city: 'Tunis',
    latitude: 36.8450,
    longitude: 10.2400,
    images: [
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Studio etudiant Cite Olympique',
    description: 'Petit studio meuble ideal pour etudiant. Proche campus universitaire et transport. Charges incluses. Disponible immediatement.',
    type: 'studio',
    transaction_type: 'rent',
    price: 350,
    surface: 28,
    rooms: 1,
    bathrooms: 1,
    address: 'Cite Olympique',
    city: 'Tunis',
    latitude: 36.8300,
    longitude: 10.1650,
    images: [
      'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800',
      'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Appartement S+4 Mutuelleville',
    description: 'Grand appartement familial de 4 chambres a Mutuelleville. Lumineux, bien entretenu, balcon, parking. Proche ecoles et hopitaux.',
    type: 'apartment',
    transaction_type: 'sale',
    price: 380000,
    surface: 160,
    rooms: 4,
    bathrooms: 2,
    address: 'Mutuelleville',
    city: 'Tunis',
    latitude: 36.8120,
    longitude: 10.1850,
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=800',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'
    ],
    owner_id: 1
  },
  {
    title: 'Maison avec jardin Bardo',
    description: 'Belle maison familiale au Bardo. Grand jardin arbore, 3 chambres, garage double. Quartier calme proche musee et transport.',
    type: 'house',
    transaction_type: 'sale',
    price: 340000,
    surface: 190,
    rooms: 3,
    bathrooms: 2,
    address: 'Le Bardo',
    city: 'Tunis',
    latitude: 36.8090,
    longitude: 10.1400,
    images: [
      'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
      'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
      'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800'
    ],
    owner_id: 1
  }
];

async function addHomePageProperties() {
  try {
    console.log('🌐 Connecting to Render production database...\n');
    
    await pool.query('SELECT NOW()');
    console.log('✅ Connected to production database\n');
    
    const countResult = await pool.query('SELECT COUNT(*) FROM properties');
    console.log(`📊 Current properties: ${countResult.rows[0].count}\n`);
    
    console.log('🏗️  Adding properties for home page (Tunis area)...\n');
    
    let created = 0;
    
    for (const prop of homePageProperties) {
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
        Math.max(1, prop.rooms - 1),
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
      
      console.log(`✅ ${created}/${homePageProperties.length} - Created: ${result.rows[0].title}`);
      console.log(`   📍 ${prop.address} (${prop.latitude}, ${prop.longitude})`);
      console.log(`   📸 ${prop.images.length} photos\n`);
    }
    
    const newCountResult = await pool.query('SELECT COUNT(*) FROM properties');
    console.log(`\n🎉 Done! Total properties now: ${newCountResult.rows[0].count}`);
    console.log(`📱 Ces ${created} annonces s'afficheront sur la page d'accueil (Tunis area)`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

addHomePageProperties();
