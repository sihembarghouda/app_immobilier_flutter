// src/controllers/upload.controller.js
const pool = require('../config/database');
const fs = require('fs');
const path = require('path');
const cloudinaryService = require('../services/cloudinary.service');

// Upload web (generic multipart: field name 'image')
exports.uploadWeb = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false,
        message: 'Aucune image fournie' 
      });
    }

    console.log('📤 Starting Cloudinary upload...');
    console.log('File path:', req.file.path);
    console.log('File exists:', fs.existsSync(req.file.path));
    console.log('Cloudinary config:', {
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET ? '***' : 'NOT SET'
    });

    // Upload to Cloudinary
    const cloudinaryUrl = await cloudinaryService.uploadImage(
      req.file.path,
      'immobilier/properties'
    );

    console.log('✅ Cloudinary upload successful:', cloudinaryUrl);

    // Delete local file after upload
    try {
      fs.unlinkSync(req.file.path);
    } catch (err) {
      console.error('Error deleting local file:', err);
    }

    res.status(200).json({
      success: true,
      message: 'Image uploadée avec succès',
      imageUrl: cloudinaryUrl,
      data: {
        url: cloudinaryUrl
      }
    });
  } catch (error) {
    console.error('❌ Error uploading web image:', error);
    console.error('Error details:', error.message);
    console.error('Error stack:', error.stack);
    
    // Delete uploaded file on error
    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (_) {}
    }
    
    res.status(500).json({ 
      success: false,
      message: 'Erreur lors du téléchargement de l\'image',
      error: error.message
    });
  }
};

// Upload profile image
exports.uploadProfileImage = async (req, res) => {
  const client = await pool.connect();
  
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucune image fournie' });
    }

    const userId = req.user.id;

    // Upload to Cloudinary
    const cloudinaryUrl = await cloudinaryService.uploadImage(
      req.file.path,
      'immobilier/profiles'
    );

    // Delete local file after upload
    try {
      fs.unlinkSync(req.file.path);
    } catch (err) {
      console.error('Error deleting local file:', err);
    }

    // Get old image to delete it from Cloudinary
    const oldImageResult = await client.query(
      'SELECT avatar FROM users WHERE id = $1',
      [userId]
    );

    // Update user profile image
    await client.query(
      'UPDATE users SET avatar = $1 WHERE id = $2',
      [cloudinaryUrl, userId]
    );

    // Delete old image from Cloudinary if exists
    if (oldImageResult.rows[0]?.avatar) {
      const oldUrl = oldImageResult.rows[0].avatar;
      if (oldUrl && oldUrl.includes('cloudinary.com')) {
        try {
          const publicId = cloudinaryService.extractPublicId(oldUrl);
          if (publicId) {
            await cloudinaryService.deleteImage(publicId);
          }
        } catch (err) {
          console.error('Error deleting old image from Cloudinary:', err);
        }
      }
    }

    res.json({
      message: 'Photo de profil mise à jour avec succès',
      imageUrl: cloudinaryUrl,
      data: {
        url: cloudinaryUrl
      }
    });
  } catch (error) {
    console.error('Error uploading profile image:', error);
    
    // Delete uploaded file on error
    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (_) {}
    }
    
    res.status(500).json({ error: 'Erreur lors du téléchargement de l\'image' });
  } finally {
    client.release();
  }
};

// Upload property images
exports.uploadPropertyImages = async (req, res) => {
  const client = await pool.connect();
  
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'Aucune image fournie' });
    }

    const { propertyId } = req.params;
    const userId = req.user.id;

    // Verify property ownership
    const propertyCheck = await client.query(
      'SELECT owner_id FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyCheck.rows.length === 0) {
      // Delete uploaded files
      req.files.forEach(file => {
        const filePath = path.join(__dirname, '../../uploads/properties', file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      });
      return res.status(404).json({ error: 'Propriété non trouvée' });
    }

    if (propertyCheck.rows[0].owner_id !== userId) {
      // Delete uploaded files
      req.files.forEach(file => {
        const filePath = path.join(__dirname, '../../uploads/properties', file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      });
      return res.status(403).json({ error: 'Non autorisé' });
    }

    // Build array of image URLs
    const imageUrls = req.files.map(file => `/uploads/properties/${file.filename}`);

    // Get existing images
    const existingResult = await client.query(
      'SELECT images FROM properties WHERE id = $1',
      [propertyId]
    );

    const existingImages = existingResult.rows[0]?.images || [];
    const updatedImages = [...existingImages, ...imageUrls];

    // Update property images
    await client.query(
      'UPDATE properties SET images = $1 WHERE id = $2',
      [updatedImages, propertyId]
    );

    res.json({
      message: 'Images ajoutées avec succès',
      images: updatedImages
    });
  } catch (error) {
    console.error('Error uploading property images:', error);
    
    // Delete uploaded files on error
    if (req.files) {
      req.files.forEach(file => {
        const filePath = path.join(__dirname, '../../uploads/properties', file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      });
    }
    
    res.status(500).json({ error: 'Erreur lors du téléchargement des images' });
  } finally {
    client.release();
  }
};

// Delete property image
exports.deletePropertyImage = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { propertyId } = req.params;
    const { imageUrl } = req.body;
    const userId = req.user.id;

    // Verify property ownership
    const propertyCheck = await client.query(
      'SELECT owner_id, images FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Propriété non trouvée' });
    }

    if (propertyCheck.rows[0].owner_id !== userId) {
      return res.status(403).json({ error: 'Non autorisé' });
    }

    const existingImages = propertyCheck.rows[0].images || [];
    const updatedImages = existingImages.filter(img => img !== imageUrl);

    // Update property images
    await client.query(
      'UPDATE properties SET images = $1 WHERE id = $2',
      [updatedImages, propertyId]
    );

    // Delete file from filesystem
    const filePath = path.join(__dirname, '../../', imageUrl);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    res.json({
      message: 'Image supprimée avec succès',
      images: updatedImages
    });
  } catch (error) {
    console.error('Error deleting property image:', error);
    res.status(500).json({ error: 'Erreur lors de la suppression de l\'image' });
  } finally {
    client.release();
  }
};
