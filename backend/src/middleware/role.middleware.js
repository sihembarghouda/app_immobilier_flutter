// src/middleware/role.middleware.js
// Middleware pour vérifier les rôles utilisateur

/**
 * Vérifie si l'utilisateur a le rôle requis
 * @param {string|string[]} allowedRoles - Rôle(s) autorisé(s) ('visiteur', 'acheteur', 'vendeur')
 */
const checkRole = (allowedRoles) => {
  return async (req, res, next) => {
    try {
      // L'utilisateur doit être authentifié (via authMiddleware)
      if (!req.user || !req.user.id) {
        return res.status(401).json({
          success: false,
          message: 'Authentification requise'
        });
      }

      // Récupérer le rôle de l'utilisateur depuis la base de données
      const { Pool } = require('pg');
      const pool = new Pool({
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME || 'immobilier_db'
      });

      const client = await pool.connect();
      
      try {
        const result = await client.query(
          'SELECT role FROM users WHERE id = $1',
          [req.user.id]
        );

        if (result.rows.length === 0) {
          return res.status(404).json({
            success: false,
            message: 'Utilisateur non trouvé'
          });
        }

        const userRole = result.rows[0].role;

        // Convertir allowedRoles en tableau si c'est une string
        const rolesArray = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

        // Vérifier si le rôle de l'utilisateur est autorisé
        if (!rolesArray.includes(userRole)) {
          return res.status(403).json({
            success: false,
            message: `Accès refusé. Rôle requis: ${rolesArray.join(' ou ')}. Votre rôle: ${userRole}`
          });
        }

        // Ajouter le rôle à req.user pour utilisation ultérieure
        req.user.role = userRole;
        next();
      } finally {
        client.release();
        await pool.end();
      }
    } catch (error) {
      console.error('Role middleware error:', error);
      return res.status(500).json({
        success: false,
        message: 'Erreur lors de la vérification du rôle'
      });
    }
  };
};

/**
 * Middleware pour les fonctionnalités acheteur (acheteur + vendeur)
 */
const requireAcheteur = checkRole(['buyer', 'seller', 'acheteur', 'vendeur']);

/**
 * Middleware pour les fonctionnalités vendeur uniquement
 */
const requireVendeur = checkRole(['seller', 'vendeur']);

/**
 * Middleware pour les fonctionnalités accessibles à tous les utilisateurs authentifiés
 * (visiteur, acheteur, vendeur)
 */
const requireAuthenticated = checkRole(['visitor', 'buyer', 'seller', 'visiteur', 'acheteur', 'vendeur']);

/**
 * Middleware pour vérifier que l'utilisateur peut modifier une propriété
 * (doit être le propriétaire ou admin)
 */
const canEditProperty = async (req, res, next) => {
  try {
    const propertyId = req.params.id || req.body.property_id;
    
    if (!propertyId) {
      return res.status(400).json({
        success: false,
        message: 'ID de propriété manquant'
      });
    }

    const { Pool } = require('pg');
    const pool = new Pool({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME || 'immobilier_db'
    });

    const client = await pool.connect();
    
    try {
      const result = await client.query(
        'SELECT owner_id FROM properties WHERE id = $1',
        [propertyId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Propriété non trouvée'
        });
      }

      const ownerId = result.rows[0].owner_id;

      if (ownerId !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'Vous n\'êtes pas autorisé à modifier cette propriété'
        });
      }

      next();
    } finally {
      client.release();
      await pool.end();
    }
  } catch (error) {
    console.error('Can edit property error:', error);
    return res.status(500).json({
      success: false,
      message: 'Erreur lors de la vérification des permissions'
    });
  }
};

module.exports = {
  checkRole,
  requireAcheteur,
  requireVendeur,
  requireAuthenticated,
  canEditProperty
};
