// src/middleware/auth.middleware.js
const jwt = require('jsonwebtoken');

const authMiddleware = async (req, res, next) => {
  try {
    // Get token from multiple locations (header, custom header, query, cookie)
    const rawAuthHeader = req.headers.authorization || req.headers.Authorization;
    const xAccessToken = req.headers['x-access-token'];
    const queryToken = req.query && (req.query.token || req.query.access_token);
    const cookieToken = req.cookies && (req.cookies.token || req.cookies.access_token);

    console.log('🔍 Auth middleware - Path:', req.path);
    console.log('🔍 Auth middleware - Headers:', rawAuthHeader ? 'Authorization present' : 'No Authorization header');

    let token = null;
    if (rawAuthHeader && typeof rawAuthHeader === 'string' && rawAuthHeader.startsWith('Bearer ')) {
      token = rawAuthHeader.split(' ')[1];
    } else if (typeof xAccessToken === 'string') {
      token = xAccessToken;
    } else if (typeof queryToken === 'string') {
      token = queryToken;
    } else if (typeof cookieToken === 'string') {
      token = cookieToken;
    }

    if (!token) {
      console.log('❌ No token provided (checked header, x-access-token, query, cookies)');
      console.log('❌ Received header:', rawAuthHeader);
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }
    
    if (!token) {
      console.log('❌ No token in authorization header after split');
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    console.log('🔐 Token received (first 20 chars):', token.substring(0, 20) + '...');
    console.log('🔐 JWT_SECRET exists:', !!process.env.JWT_SECRET);
    console.log('🔐 JWT_SECRET (first 10 chars):', process.env.JWT_SECRET ? process.env.JWT_SECRET.substring(0, 10) + '...' : 'UNDEFINED');

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    console.log('✅ Token verified successfully for user:', decoded.id, 'email:', decoded.email);
    
    // Add user info to request
    req.user = {
      id: decoded.id,
      email: decoded.email
    };

    next();
  } catch (error) {
    console.log('❌ Token verification error:', error.name, '-', error.message);
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }
    
    if (error.name === 'JsonWebTokenError') {
      console.log('❌ JWT Error - Invalid token signature or structure');
    }
    
    return res.status(401).json({
      success: false,
      message: 'Invalid token'
    });
  }
};

module.exports = authMiddleware;