/**
 * Configuration module for the application
 * Centralizes all environment variables and configuration settings
 */

// Server configuration
const PORT = process.env.PORT || 3000;

// VNC service configuration
const VNC_SERVICE_HOST = process.env.VNC_SERVICE_HOST || 'remote-desktop-service';
const VNC_SERVICE_PORT = process.env.VNC_SERVICE_PORT || 6901;
const VNC_PASSWORD = process.env.VNC_PASSWORD || 'bakku-the-wizard'; // Default password

module.exports = {
    PORT,
    VNC_SERVICE_HOST,
    VNC_SERVICE_PORT,
    VNC_PASSWORD
}; 