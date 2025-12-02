const axios = require('axios');

const API_URL = 'https://immobilier-backend.onrender.com/api';

// Using your account credentials
const LOGIN_EMAIL = 'sihembarghouda93@gmail.com';
const LOGIN_PASSWORD = 'barghouda123';

// Property IDs and their corresponding images (Unsplash real estate photos)
const propertyPhotos = [
  {
    title: 'Appartement S+3 vue mer',
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'
    ]
  },
  {
    title: 'Villa moderne avec piscine',
    images: [
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800'
    ]
  },
  {
    title: 'Studio meuble centre ville',
    images: [
      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
      'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800'
    ]
  },
  {
    title: 'Maison traditionnelle renovee',
    images: [
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800'
    ]
  },
  {
    title: 'Appartement S+2 neuf',
    images: [
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      'https://images.unsplash.com/photo-1556912173-46c336c7fd55?w=800'
    ]
  },
  {
    title: 'Villa pieds dans eau',
    images: [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800'
    ]
  },
  {
    title: 'Studio etudiant',
    images: [
      'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
      'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800'
    ]
  },
  {
    title: 'Maison avec jardin',
    images: [
      'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
      'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
      'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800'
    ]
  }
];

async function login() {
  try {
    const response = await axios.post(`${API_URL}/auth/login`, {
      email: LOGIN_EMAIL,
      password: LOGIN_PASSWORD
    });
    return response.data.token;
  } catch (error) {
    console.error('❌ Login failed:', error.response?.data || error.message);
    throw error;
  }
}

async function getAllProperties(token) {
  try {
    const response = await axios.get(`${API_URL}/properties`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    return response.data;
  } catch (error) {
    console.error('❌ Failed to get properties:', error.response?.data || error.message);
    throw error;
  }
}

async function updatePropertyImages(token, propertyId, images) {
  try {
    const response = await axios.put(
      `${API_URL}/properties/${propertyId}`,
      { images: images },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    return response.data;
  } catch (error) {
    console.error('❌ Failed to update property:', error.response?.data || error.message);
    throw error;
  }
}

async function main() {
  try {
    // Login
    console.log('🔑 Logging in...');
    const token = await login();
    console.log('✅ Login successful\n');

    // Get all properties
    console.log('📋 Fetching all properties...');
    const properties = await getAllProperties(token);
    console.log(`✅ Found ${properties.length} properties\n`);

    // Update each property with photos
    let updated = 0;
    for (const photoData of propertyPhotos) {
      // Find the property by title
      const property = properties.find(p => p.title.includes(photoData.title.split(' ')[0]));
      
      if (property) {
        console.log(`📸 Updating: ${property.title}`);
        await updatePropertyImages(token, property.id, photoData.images);
        console.log(`✅ Added ${photoData.images.length} photos\n`);
        updated++;
      } else {
        console.log(`⚠️  Property not found: ${photoData.title}\n`);
      }
    }

    console.log(`\n🎉 Done! Updated ${updated}/${propertyPhotos.length} properties with photos.`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();
