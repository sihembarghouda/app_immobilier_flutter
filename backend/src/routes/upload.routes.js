// src/routes/upload.routes.js
const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/upload.controller');
const authMiddleware = require('../middleware/auth.middleware');
const { uploadSingle, uploadMultiple } = require('../middleware/upload.middleware');

// Upload profile image
router.post('/profile', authMiddleware, uploadSingle, uploadController.uploadProfileImage);

// Upload property images
router.post('/property/:propertyId', authMiddleware, uploadMultiple, uploadController.uploadPropertyImages);

// Upload web (profile or property)
router.post('/web', authMiddleware, uploadSingle, uploadController.uploadWeb);

// Delete property image
router.delete('/property/:propertyId/image', authMiddleware, uploadController.deletePropertyImage);

module.exports = router;
