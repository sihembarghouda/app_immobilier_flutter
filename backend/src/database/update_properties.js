// Script to update existing properties with more realistic information
require('dotenv').config();
const { Client } = require('pg');

const updateProperties = async () => {
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

    // Get all properties
    const result = await client.query('SELECT id, type, city, transaction_type FROM properties');
    console.log(`📊 Found ${result.rows.length} properties to update`);

    const realImages = {
      apartment: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        'https://images.unsplash.com/photo-1536376072261-38c75010e6c9',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
      ],
      house: [
        'https://images.unsplash.com/photo-1568605114967-8130f3a36994',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c',
        'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3',
        'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde',
      ],
      villa: [
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
        'https://images.unsplash.com/photo-1600607687644-aacaf9255ccb',
        'https://images.unsplash.com/photo-1613977257363-707ba9348227',
      ],
      studio: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        'https://images.unsplash.com/photo-1536376072261-38c75010e6c9',
      ],
    };

    const descriptions = {
      apartment: [
        'Bel appartement moderne avec finitions haut de gamme. Cuisine équipée, double vitrage, climatisation. Proche de toutes commodités.',
        'Appartement spacieux et lumineux dans une résidence sécurisée. Vue dégagée, parking inclus. Idéal pour une famille.',
        'Superbe appartement rénové avec goût. Pièces de vie généreuses, balcon ensoleillé. Quartier calme et recherché.',
        'Appartement contemporain au dernier étage. Terrasse panoramique, ascenseur, cave. Aucun travaux à prévoir.',
      ],
      house: [
        'Maison familiale avec jardin arboré. Garage double, 4 chambres spacieuses. Quartier résidentiel calme.',
        'Belle maison de ville sur 3 niveaux. Séjour cathédrale, cuisine ouverte, terrasse. Excellent état général.',
        'Charmante maison individuelle avec piscine. Grand terrain clos, barbecue. Idéale pour recevoir.',
        'Maison récente aux prestations soignées. Cuisine équipée, dressing, bureau. Proche écoles et commerces.',
      ],
      villa: [
        'Villa d\'exception avec vue mer. Piscine à débordement, jardin paysager, garage 3 voitures. Prestations luxueuses.',
        'Magnifique villa contemporaine. Architecture moderne, domotique, home cinéma. Secteur prisé et sécurisé.',
        'Villa de prestige sur grand terrain. Piscine chauffée, pool house, terrain de tennis. Calme absolu.',
        'Superbe villa avec vue panoramique. 5 suites, spa, cave à vin. Finitions exceptionnelles.',
      ],
      studio: [
        'Studio cosy et fonctionnel. Coin cuisine équipé, salle d\'eau moderne. Parfait pour étudiant ou investissement.',
        'Beau studio rénové avec mezzanine. Rangements optimisés, double vitrage. Proche transports et fac.',
        'Studio lumineux avec balcon. Immeuble bien entretenu, charges modérées. Bon rapport qualité-prix.',
        'Joli studio dans résidence récente. Ascenseur, parking, cave. Idéal premier achat.',
      ],
    };

    let updated = 0;
    
    for (const property of result.rows) {
      const typeImages = realImages[property.type] || realImages.apartment;
      const typeDescriptions = descriptions[property.type] || descriptions.apartment;
      
      // Select random images (3-5 images)
      const numImages = Math.floor(Math.random() * 3) + 3;
      const selectedImages = [];
      const shuffled = [...typeImages].sort(() => 0.5 - Math.random());
      for (let i = 0; i < Math.min(numImages, shuffled.length); i++) {
        selectedImages.push(shuffled[i]);
      }
      
      // Select random description
      const description = typeDescriptions[Math.floor(Math.random() * typeDescriptions.length)];
      
      await client.query(
        'UPDATE properties SET images = $1, description = $2 WHERE id = $3',
        [selectedImages, description, property.id]
      );
      
      updated++;
      if (updated % 100 === 0) {
        console.log(`✅ Updated ${updated} properties...`);
      }
    }

    console.log(`\n✅ Successfully updated ${updated} properties with realistic data!`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await client.end();
  }
};

updateProperties();
