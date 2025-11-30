// src/middleware/optional-auth.middleware.js
const jwt = require('jsonwebtoken');

/**
 * Middleware d'authentification optionnelle
 * Si un token est présent, il est vérifié et l'utilisateur est attaché à req.user
 * Si aucun token n'est présent, la requête continue sans utilisateur
 * Utilisé pour les endpoints publics qui peuvent avoir un comportement différent pour les utilisateurs connectés
 */
const optionalAuthMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    // Si pas de header, continuer sans utilisateur
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      req.user = null;
      return next();
    }

    const token = authHeader.split(' ')[1];
    
    if (!token) {
      req.user = null;
      return next();
    }

    try {
      // Essayer de vérifier le token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      req.user = {
        id: decoded.id,
        email: decoded.email
      };
      
      console.log('✅ Optional auth - User authenticated:', decoded.id);
    } catch (error) {
      // Token invalide, mais on continue sans utilisateur
      console.log('⚠️  Optional auth - Invalid token, continuing without user');
      req.user = null;
    }

    next();
  } catch (error) {
    // En cas d'erreur, continuer sans utilisateur
    req.user = null;
    next();
  }
};

module.exports = optionalAuthMiddleware;
