const https = require('https');

// Login first to get token
const loginData = JSON.stringify({ email: 'demo@immobilier.tn', password: 'demo123' });

function request(options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body }));
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

const properties = [
  {
    title: 'Appartement S+3 vue mer',
    description: 'Magnifique appartement de 150m2 avec une vue imprenable sur la mer. Cuisine equipee, climatisation, parking prive. Proche de toutes commodites.',
    type: 'apartment',
    transaction_type: 'sale',
    price: 320000,
    surface: 150,
    rooms: 4,
    bedrooms: 3,
    bathrooms: 2,
    address: 'Avenue Habib Bourguiba',
    city: 'La Marsa',
    latitude: 36.8781,
    longitude: 10.3247
  },
  {
    title: 'Villa moderne avec piscine',
    description: 'Superbe villa recente de 350m2 sur un terrain de 600m2. Piscine chauffee, jardin paysager, garage pour 2 voitures. Quartier residentiel calme.',
    type: 'villa',
    transaction_type: 'sale',
    price: 850000,
    surface: 350,
    rooms: 6,
    bedrooms: 4,
    bathrooms: 3,
    address: 'Residence Les Jardins',
    city: 'Gammarth',
    latitude: 36.9068,
    longitude: 10.3151
  },
  {
    title: 'Studio meuble centre ville',
    description: 'Studio de 45m2 entierement meuble et equipe. Ideal pour etudiant ou jeune professionnel. Proche metro et commerces.',
    type: 'studio',
    transaction_type: 'rent',
    price: 800,
    surface: 45,
    rooms: 1,
    bedrooms: 1,
    bathrooms: 1,
    address: 'Rue de la Liberte',
    city: 'Tunis',
    latitude: 36.8065,
    longitude: 10.1815
  },
  {
    title: 'Maison traditionnelle renovee',
    description: 'Charmante maison tunisienne de 200m2 entierement renovee. Architecture traditionnelle avec confort moderne. Patio central, terrasse.',
    type: 'house',
    transaction_type: 'sale',
    price: 420000,
    surface: 200,
    rooms: 5,
    bedrooms: 3,
    bathrooms: 2,
    address: 'Medina',
    city: 'Hammamet',
    latitude: 36.4000,
    longitude: 10.6167
  },
  {
    title: 'Appartement S+2 neuf',
    description: 'Appartement neuf de 95m2 au 3eme etage avec ascenseur. Finitions haut de gamme, double vitrage, cuisine americaine.',
    type: 'apartment',
    transaction_type: 'rent',
    price: 1200,
    surface: 95,
    rooms: 3,
    bedrooms: 2,
    bathrooms: 1,
    address: 'Residence Emeraude',
    city: 'Sousse',
    latitude: 35.8256,
    longitude: 10.6369
  },
  {
    title: 'Villa pieds dans eau',
    description: 'Villa exception de 280m2 acces direct a la plage. 5 chambres, salon panoramique, cuisine ete. Rare sur le marche.',
    type: 'villa',
    transaction_type: 'sale',
    price: 1200000,
    surface: 280,
    rooms: 7,
    bedrooms: 5,
    bathrooms: 4,
    address: 'Route de la Corniche',
    city: 'Sidi Bou Said',
    latitude: 36.8685,
    longitude: 10.3419
  },
  {
    title: 'Studio etudiant',
    description: 'Studio compact de 30m2 parfait pour etudiant. Kitchenette equipee, salle de bain. A 5 min de universite.',
    type: 'studio',
    transaction_type: 'rent',
    price: 450,
    surface: 30,
    rooms: 1,
    bedrooms: 1,
    bathrooms: 1,
    address: 'Rue de Marseille',
    city: 'Tunis',
    latitude: 36.8008,
    longitude: 10.1865
  },
  {
    title: 'Maison avec jardin',
    description: 'Belle maison de 180m2 avec grand jardin de 400m2. 4 chambres spacieuses, salon salle a manger, garage. Quartier familial.',
    type: 'house',
    transaction_type: 'sale',
    price: 380000,
    surface: 180,
    rooms: 5,
    bedrooms: 4,
    bathrooms: 2,
    address: 'Cite El Khadra',
    city: 'Sfax',
    latitude: 34.7406,
    longitude: 10.7603
  }
];

(async ()=>{
  try {
    // Login
    const loginOpts = {
      hostname: 'immobilier-backend.onrender.com', port: 443, path: '/api/auth/login', method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': loginData.length }
    };
    const loginRes = await request(loginOpts, loginData);
    console.log('✅ Login successful');
    const parsed = JSON.parse(loginRes.body);
    if (!parsed.success) {
      console.error('Login failed:', loginRes.body);
      return;
    }
    const token = parsed.data.token;

    // Create properties
    for (let i = 0; i < properties.length; i++) {
      const prop = properties[i];
      const propertyData = JSON.stringify(prop);
      
      const propOpts = {
        hostname: 'immobilier-backend.onrender.com', port: 443, path: '/api/properties', method: 'POST',
        headers: { 
          'Content-Type': 'application/json', 
          'Content-Length': propertyData.length, 
          'Authorization': 'Bearer ' + token 
        }
      };

      const propRes = await request(propOpts, propertyData);
      const result = JSON.parse(propRes.body);
      
      if (result.success) {
        console.log(`✅ ${i + 1}/${properties.length} - Created: ${prop.title} (${prop.city})`);
      } else {
        console.log(`❌ ${i + 1}/${properties.length} - Failed: ${prop.title} - ${result.message}`);
      }
      
      // Small delay between requests
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('\n🎉 All done! Total properties created successfully.');
  } catch (e) {
    console.error('❌ Error:', e);
  }
})();
