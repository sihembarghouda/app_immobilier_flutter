// src/database/seed_properties.js
require('dotenv').config();
const { Client } = require('pg');

const cities = [
  { name: 'Tunis', lat: 36.8065, lng: 10.1815 },
  { name: 'Sfax', lat: 34.7406, lng: 10.7603 },
  { name: 'Sousse', lat: 35.8256, lng: 10.6369 },
  { name: 'Kairouan', lat: 35.6781, lng: 10.0963 },
  { name: 'Bizerte', lat: 37.2746, lng: 9.8739 },
  { name: 'Gabès', lat: 33.8815, lng: 10.0982 },
  { name: 'Ariana', lat: 36.8625, lng: 10.1956 },
  { name: 'Gafsa', lat: 34.425, lng: 8.7842 },
  { name: 'Monastir', lat: 35.7774, lng: 10.8263 },
  { name: 'Ben Arous', lat: 36.7473, lng: 10.2242 },
  { name: 'Kasserine', lat: 35.1675, lng: 8.8306 },
  { name: 'Médenine', lat: 33.3545, lng: 10.5055 },
  { name: 'Nabeul', lat: 36.4561, lng: 10.7376 },
  { name: 'Tataouine', lat: 32.9296, lng: 10.4517 },
  { name: 'Béja', lat: 36.7256, lng: 9.1817 },
  { name: 'Jendouba', lat: 36.5011, lng: 8.7805 },
  { name: 'Mahdia', lat: 35.5047, lng: 11.0622 },
  { name: 'Siliana', lat: 36.0847, lng: 9.3708 },
  { name: 'Kef', lat: 36.1743, lng: 8.7049 },
  { name: 'Tozeur', lat: 33.9197, lng: 8.1335 },
];

const propertyTypes = ['apartment', 'house', 'villa', 'studio'];
const transactionTypes = ['sale', 'rent'];

const titles = {
  apartment: [
    'Appartement moderne avec vue',
    'Bel appartement lumineux',
    'Appartement spacieux',
    'Appartement rénové récemment',
    'Appartement dans résidence sécurisée',
    'Appartement avec balcon',
    'Appartement de standing',
    'Appartement proche commodités',
  ],
  house: [
    'Maison familiale spacieuse',
    'Belle maison avec jardin',
    'Maison traditionnelle rénovée',
    'Maison dans quartier calme',
    'Maison avec terrasse',
    'Maison de plain-pied',
    'Maison contemporaine',
    'Maison avec garage',
  ],
  villa: [
    'Villa luxueuse avec piscine',
    'Magnifique villa moderne',
    'Villa avec vue panoramique',
    'Villa de prestige',
    'Villa contemporaine',
    'Villa spacieuse et élégante',
    'Villa avec jardin paysager',
    'Villa haut standing',
  ],
  studio: [
    'Studio meublé',
    'Studio moderne',
    'Studio bien situé',
    'Studio lumineux',
    'Studio rénové',
    'Studio équipé',
    'Studio confortable',
    'Studio proche centre',
  ],
};

const descriptions = [
  'Idéal pour famille, proche de toutes les commodités. Très bien entretenu.',
  'Dans un quartier recherché, avec toutes les commodités à proximité.',
  'Excellente opportunité d\'investissement dans un secteur en développement.',
  'Propriété bien entretenue avec finitions de qualité.',
  'Emplacement privilégié, proche des écoles et transports en commun.',
  'Environnement calme et sécurisé, parfait pour vivre en famille.',
  'Vue dégagée, bien exposé, climatisation, chauffage central.',
  'Récemment rénové avec des matériaux de qualité.',
  'Parfait pour investisseur ou première acquisition.',
  'Rare sur le marché, à visiter absolument.',
];

const streets = [
  'Avenue Habib Bourguiba',
  'Rue de la République',
  'Avenue de Paris',
  'Rue de Marseille',
  'Boulevard du 7 Novembre',
  'Avenue Mohamed V',
  'Rue de la Liberté',
  'Avenue Hédi Chaker',
  'Rue Ibn Khaldoun',
  'Avenue Farhat Hached',
];

const images = [
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
  'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
  'https://images.unsplash.com/photo-1502672260066-6bc35f0c99f0',
  'https://images.unsplash.com/photo-1568605114967-8130f3a36994',
  'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
  'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
  'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c',
  'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
  'https://images.unsplash.com/photo-1600607687644-c7171b42498b',
];

function random(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomChoice(array) {
  return array[random(0, array.length - 1)];
}

function randomLatLng(baseLat, baseLng, radius = 0.1) {
  const lat = baseLat + (Math.random() - 0.5) * radius;
  const lng = baseLng + (Math.random() - 0.5) * radius;
  return { lat: parseFloat(lat.toFixed(6)), lng: parseFloat(lng.toFixed(6)) };
}

const seedProperties = async () => {
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

    // Get user IDs
    const usersResult = await client.query('SELECT id FROM users');
    const userIds = usersResult.rows.map(row => row.id);

    if (userIds.length === 0) {
      console.error('❌ No users found. Please run migration first.');
      process.exit(1);
    }

    console.log(`📝 Found ${userIds.length} users`);
    console.log('📝 Generating 1500 properties...');

    const batchSize = 100;
    const totalProperties = 1500;
    let insertedCount = 0;

    for (let batch = 0; batch < totalProperties / batchSize; batch++) {
      const values = [];
      const placeholders = [];
      let paramIndex = 1;

      for (let i = 0; i < batchSize; i++) {
        const city = randomChoice(cities);
        const type = randomChoice(propertyTypes);
        const transactionType = randomChoice(transactionTypes);
        const title = randomChoice(titles[type]);
        const description = randomChoice(descriptions);
        const street = randomChoice(streets);
        const image = randomChoice(images);
        
        const coords = randomLatLng(city.lat, city.lng);
        
        let price, surface, rooms, bedrooms, bathrooms;
        
        if (type === 'studio') {
          surface = random(25, 50);
          rooms = 1;
          bedrooms = 1;
          bathrooms = 1;
          price = transactionType === 'sale' ? random(50000, 120000) : random(400, 800);
        } else if (type === 'apartment') {
          surface = random(60, 150);
          rooms = random(2, 5);
          bedrooms = random(1, 3);
          bathrooms = random(1, 2);
          price = transactionType === 'sale' ? random(100000, 400000) : random(600, 1500);
        } else if (type === 'house') {
          surface = random(120, 300);
          rooms = random(4, 7);
          bedrooms = random(2, 5);
          bathrooms = random(2, 3);
          price = transactionType === 'sale' ? random(200000, 600000) : random(1000, 2500);
        } else { // villa
          surface = random(250, 500);
          rooms = random(6, 10);
          bedrooms = random(3, 6);
          bathrooms = random(2, 4);
          price = transactionType === 'sale' ? random(500000, 1500000) : random(2000, 5000);
        }

        const ownerId = randomChoice(userIds);

        placeholders.push(
          `($${paramIndex}, $${paramIndex + 1}, $${paramIndex + 2}, $${paramIndex + 3}, $${paramIndex + 4}, $${paramIndex + 5}, $${paramIndex + 6}, $${paramIndex + 7}, $${paramIndex + 8}, $${paramIndex + 9}, $${paramIndex + 10}, $${paramIndex + 11}, $${paramIndex + 12}, $${paramIndex + 13}, $${paramIndex + 14})`
        );

        values.push(
          `${title} - ${city.name}`,
          description,
          type,
          transactionType,
          price,
          surface,
          rooms,
          bedrooms,
          bathrooms,
          `${street}, ${city.name}`,
          city.name,
          coords.lat,
          coords.lng,
          [image],
          ownerId
        );

        paramIndex += 15;
      }

      const query = `
        INSERT INTO properties (
          title, description, type, transaction_type, price, surface, 
          rooms, bedrooms, bathrooms, address, city, latitude, longitude, 
          images, owner_id
        ) VALUES ${placeholders.join(', ')}
      `;

      await client.query(query, values);
      insertedCount += batchSize;
      console.log(`✅ Inserted ${insertedCount}/${totalProperties} properties`);
    }

    console.log(`\n🎉 Successfully seeded ${1500} properties!`);
    await client.end();
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seedProperties();
