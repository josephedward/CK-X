/**
 * Proxy middleware module
 * Sets up the proxies for VNC connections
 */

const { createProxyMiddleware } = require('http-proxy-middleware');
const config = require('../config/config');

/**
 * Creates the VNC proxy configuration object
 * @returns {Object} Proxy configuration
 */
function createVncProxyConfig() {
    return {
        target: `http://${config.VNC_SERVICE_HOST}:${config.VNC_SERVICE_PORT}`,
        changeOrigin: true,
        ws: true,
        secure: false,
        pathRewrite: {
            '^/vnc-proxy': ''
        },
        onProxyReq: (proxyReq, req, res) => {
            // Log HTTP requests being proxied
            console.log(`Proxying HTTP request to VNC server: ${req.url}`);
        },
        onProxyReqWs: (proxyReq, req, socket, options, head) => {
            // Log WebSocket connections
            console.log(`WebSocket connection established to VNC server: ${req.url}`);
        },
        onProxyRes: (proxyRes, req, res) => {
            // Log the responses from VNC server
            console.log(`Received response from VNC server for: ${req.url}`);
        },
        onError: (err, req, res) => {
            console.error(`Proxy error: ${err.message}`);
            if (res && res.writeHead) {
                res.writeHead(500, {
                    'Content-Type': 'text/plain'
                });
                res.end(`Proxy error: ${err.message}`);
            }
        }
    };
}

/**
 * Sets up VNC proxy middleware on the Express app
 * @param {Object} app - Express application
 */
function setupProxies(app) {
    const vncProxyConfig = createVncProxyConfig();

    // Middleware to enhance VNC URLs with authentication if needed
    app.use('/vnc-proxy', (req, res, next) => {
        // Check if the URL already has a password parameter
        if (!req.query.password) {
            // If no password provided, add default password
            console.log('Adding default VNC password to request');
            const separator = req.url.includes('?') ? '&' : '?';
            req.url = `${req.url}${separator}password=${config.VNC_PASSWORD}`;
        }
        next();
    }, createProxyMiddleware(vncProxyConfig));

    // Direct WebSocket proxy to handle the websockify endpoint
    app.use('/websockify', createProxyMiddleware({
        ...vncProxyConfig,
        pathRewrite: {
            '^/websockify': '/websockify'
        },
        ws: true,
        onProxyReqWs: (proxyReq, req, socket, options, head) => {
            // Log WebSocket connections to websockify
            console.log(`WebSocket connection to websockify established: ${req.url}`);
            
            // Add additional headers if needed
            proxyReq.setHeader('Origin', `http://${config.VNC_SERVICE_HOST}:${config.VNC_SERVICE_PORT}`);
        },
        onError: (err, req, res) => {
            console.error(`Websockify proxy error: ${err.message}`);
            if (res && res.writeHead) {
                res.writeHead(500, {
                    'Content-Type': 'text/plain'
                });
                res.end(`Websockify proxy error: ${err.message}`);
            }
        }
    }));
}

module.exports = setupProxies; 