/**
 * API Routes module
 * Defines all API endpoints for the application
 */

const express = require('express');
const router = express.Router();
const config = require('../config/config');

/**
 * GET /api/vnc-info
 * Returns information about the VNC server
 */
router.get('/vnc-info', (req, res) => {
    res.json({
        host: config.VNC_SERVICE_HOST,
        port: config.VNC_SERVICE_PORT,
        wsUrl: `/websockify`,
        defaultPassword: config.VNC_PASSWORD,
        status: 'connected'
    });
});

module.exports = router; 