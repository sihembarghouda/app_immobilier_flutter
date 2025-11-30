// seed_more_properties.js - Add many properties to database
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'immobilier_db',
  password: 'postgres',
  port: 5432,
});

const properties = [
  // France - Paris
  { title: 'Appartement lumineux Paris 16ème', type: 'apartment', transaction: 'sale', price: 450000, bedrooms: 2, bathrooms: 1, area: 55, address: '12 Rue de Passy, 75016 Paris', lat: 48.8566, lon: 2.2831, country: 'France', city: 'Paris' },
  { title: 'Studio moderne Montmartre', type: 'studio', transaction: 'rent', price: 950, bedrooms: 1, bathrooms: 1, area: 28, address: '45 Rue Lepic, 75018 Paris', lat: 48.8867, lon: 2.3358, country: 'France', city: 'Paris' },
  { title: 'Maison avec jardin Paris 15ème', type: 'house', transaction: 'sale', price: 1200000, bedrooms: 4, bathrooms: 2, area: 120, address: '89 Avenue Emile Zola, 75015 Paris', lat: 48.8467, lon: 2.2931, country: 'France', city: 'Paris' },
  
  // France - Lyon
  { title: 'Appartement T3 Lyon Part-Dieu', type: 'apartment', transaction: 'rent', price: 1200, bedrooms: 3, bathrooms: 1, area: 70, address: '15 Rue de Bonnel, 69003 Lyon', lat: 45.7603, lon: 4.8540, country: 'France', city: 'Lyon' },
  { title: 'Loft industriel Lyon Confluence', type: 'apartment', transaction: 'sale', price: 380000, bedrooms: 2, bathrooms: 2, area: 85, address: '22 Cours Charlemagne, 69002 Lyon', lat: 45.7428, lon: 4.8183, country: 'France', city: 'Lyon' },
  
  // France - Marseille
  { title: 'Villa vue mer Marseille', type: 'villa', transaction: 'sale', price: 950000, bedrooms: 5, bathrooms: 3, area: 180, address: '78 Corniche Kennedy, 13007 Marseille', lat: 43.2785, lon: 5.3546, country: 'France', city: 'Marseille' },
  { title: 'Appartement Vieux Port', type: 'apartment', transaction: 'rent', price: 850, bedrooms: 2, bathrooms: 1, area: 55, address: '12 Quai du Port, 13002 Marseille', lat: 43.2961, lon: 5.3704, country: 'France', city: 'Marseille' },
  
  // Italy - Rome
  { title: 'Appartamento Centro Storico Roma', type: 'apartment', transaction: 'rent', price: 1400, bedrooms: 2, bathrooms: 1, area: 65, address: 'Via del Corso 140, 00186 Roma', lat: 41.9028, lon: 12.4811, country: 'Italy', city: 'Rome' },
  { title: 'Villa Trastevere', type: 'villa', transaction: 'sale', price: 1800000, bedrooms: 6, bathrooms: 4, area: 250, address: 'Via di San Francesco a Ripa, 00153 Roma', lat: 41.8876, lon: 12.4707, country: 'Italy', city: 'Rome' },
  { title: 'Monolocale Prati', type: 'studio', transaction: 'rent', price: 750, bedrooms: 1, bathrooms: 1, area: 35, address: 'Via Cola di Rienzo 120, 00192 Roma', lat: 41.9072, lon: 12.4610, country: 'Italy', city: 'Rome' },
  
  // Italy - Milan
  { title: 'Attico Milano Centro', type: 'apartment', transaction: 'sale', price: 890000, bedrooms: 3, bathrooms: 2, area: 110, address: 'Via Monte Napoleone 15, 20121 Milano', lat: 45.4685, lon: 9.1953, country: 'Italy', city: 'Milan' },
  { title: 'Bilocale Navigli', type: 'apartment', transaction: 'rent', price: 1100, bedrooms: 2, bathrooms: 1, area: 60, address: 'Ripa di Porta Ticinese 55, 20143 Milano', lat: 45.4492, lon: 9.1761, country: 'Italy', city: 'Milan' },
  
  // Spain - Madrid
  { title: 'Piso Moderno Salamanca', type: 'apartment', transaction: 'sale', price: 520000, bedrooms: 3, bathrooms: 2, area: 95, address: 'Calle Serrano 85, 28006 Madrid', lat: 40.4300, lon: -3.6836, country: 'Spain', city: 'Madrid' },
  { title: 'Estudio Malasaña', type: 'studio', transaction: 'rent', price: 800, bedrooms: 1, bathrooms: 1, area: 32, address: 'Calle de San Vicente Ferrer 20, 28004 Madrid', lat: 40.4254, lon: -3.7011, country: 'Spain', city: 'Madrid' },
  
  // Spain - Barcelona
  { title: 'Ático Eixample Barcelona', type: 'apartment', transaction: 'sale', price: 650000, bedrooms: 3, bathrooms: 2, area: 100, address: 'Passeig de Gràcia 75, 08008 Barcelona', lat: 41.3926, lon: 2.1644, country: 'Spain', city: 'Barcelona' },
  { title: 'Piso Gótico', type: 'apartment', transaction: 'rent', price: 1300, bedrooms: 2, bathrooms: 1, area: 70, address: 'Carrer de la Portaferrissa 12, 08002 Barcelona', lat: 41.3825, lon: 2.1727, country: 'Spain', city: 'Barcelona' },
  
  // Germany - Berlin
  { title: 'Moderne Wohnung Mitte', type: 'apartment', transaction: 'rent', price: 1400, bedrooms: 2, bathrooms: 1, area: 75, address: 'Friedrichstraße 95, 10117 Berlin', lat: 52.5200, lon: 13.3888, country: 'Germany', city: 'Berlin' },
  { title: 'Penthouse Kreuzberg', type: 'apartment', transaction: 'sale', price: 620000, bedrooms: 3, bathrooms: 2, area: 110, address: 'Oranienstraße 45, 10969 Berlin', lat: 52.4995, lon: 13.4190, country: 'Germany', city: 'Berlin' },
  
  // Tunisia - Tunis
  { title: 'Appartement S+3 Lac 2', type: 'apartment', transaction: 'rent', price: 500, bedrooms: 3, bathrooms: 2, area: 120, address: 'Les Berges du Lac, 1053 Tunis', lat: 36.8379, lon: 10.2410, country: 'Tunisia', city: 'Tunis' },
  { title: 'Villa avec piscine La Marsa', type: 'villa', transaction: 'sale', price: 450000, bedrooms: 5, bathrooms: 3, area: 280, address: 'Avenue Habib Bourguiba, 2070 La Marsa', lat: 36.8781, lon: 10.3247, country: 'Tunisia', city: 'La Marsa' },
  
  // Commercial properties - convert to apartment type
  { title: 'Local commercial Paris Champs-Élysées', type: 'apartment', transaction: 'rent', price: 5000, bedrooms: 0, bathrooms: 1, area: 80, address: '120 Avenue des Champs-Élysées, 75008 Paris', lat: 48.8738, lon: 2.2950, country: 'France', city: 'Paris' },
  { title: 'Bureau Lyon Part-Dieu', type: 'apartment', transaction: 'rent', price: 2500, bedrooms: 0, bathrooms: 2, area: 120, address: '129 Rue Servient, 69003 Lyon', lat: 45.7603, lon: 4.8592, country: 'France', city: 'Lyon' },
  
  // Parking/Garage - convert to studio
  { title: 'Box fermé Paris 15ème', type: 'studio', transaction: 'rent', price: 150, bedrooms: 0, bathrooms: 0, area: 15, address: '45 Rue de la Convention, 75015 Paris', lat: 48.8414, lon: 2.2946, country: 'France', city: 'Paris' },
  { title: 'Garage Milano Centro', type: 'studio', transaction: 'sale', price: 45000, bedrooms: 0, bathrooms: 0, area: 20, address: 'Via Torino 38, 20123 Milano', lat: 45.4628, lon: 9.1859, country: 'Italy', city: 'Milan' },
  
  // Land/Terrain - convert to villa type
  { title: 'Terrain constructible Provence', type: 'villa', transaction: 'sale', price: 180000, bedrooms: 0, bathrooms: 0, area: 1200, address: 'Route de Lourmarin, 84160 Cadenet', lat: 43.7340, lon: 5.3733, country: 'France', city: 'Cadenet' },
  { title: 'Terreno edificabile Toscana', type: 'villa', transaction: 'sale', price: 220000, bedrooms: 0, bathrooms: 0, area: 1500, address: 'Via Chiantigiana, 50022 Greve in Chianti', lat: 43.5851, lon: 11.3171, country: 'Italy', city: 'Greve in Chianti' },
];

async function seedProperties() {
  const client = await pool.connect();
  
  try {
    console.log('Starting to seed properties...');
    
    for (const prop of properties) {
      const description = `${prop.type === 'apartment' ? 'Bel appartement' : prop.type === 'house' ? 'Belle maison' : prop.type === 'villa' ? 'Magnifique villa' : prop.type === 'studio' ? 'Studio fonctionnel' : prop.type === 'commercial' ? 'Local commercial' : prop.type === 'parking' ? 'Place de parking' : 'Terrain'} situé à ${prop.city}. ${prop.area}m². ${prop.bedrooms > 0 ? prop.bedrooms + ' chambres, ' : ''}${prop.bathrooms > 0 ? prop.bathrooms + ' salle(s) de bain.' : ''}`;
      
      const images = [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
        'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800'
      ];
      
      await client.query(
        `INSERT INTO properties 
        (title, description, price, rooms, bedrooms, bathrooms, surface, address, latitude, longitude, type, transaction_type, images, owner_id, city)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 1, $14)`,
        [
          prop.title,
          description,
          prop.price,
          prop.bedrooms + 1, // rooms = bedrooms + 1 (living room)
          prop.bedrooms,
          prop.bathrooms,
          prop.area,
          prop.address,
          prop.lat,
          prop.lon,
          prop.type,
          prop.transaction,
          images,
          prop.city
        ]
      );
      
      console.log(`✓ Added: ${prop.title}`);
    }
    
    console.log(`\n✅ Successfully added ${properties.length} properties!`);
    
  } catch (error) {
    console.error('Error seeding properties:', error);
  } finally {
    client.release();
    pool.end();
  }
}

seedProperties();
