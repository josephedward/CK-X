/**
 * Error Handler Middleware
 * Centralized error handling for the application
 */

const path = require('path');

/**
 * Global error handler middleware
 * @param {Error} err - The error object
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
function errorHandler(err, req, res, next) {
    console.error('Server error:', err);
    
    // Send a user-friendly error page
    res.status(500).sendFile(path.join(__dirname, '..', 'public', '50x.html'));
}

module.exports = errorHandler; 