const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { createProxyMiddleware } = require('http-proxy-middleware');
const http = require('http');
const socketio = require('socket.io');
const { Client } = require('ssh2');

// Server configuration
const PORT = process.env.PORT || 3000;

// VNC service configuration from environment variables
const VNC_SERVICE_HOST = process.env.VNC_SERVICE_HOST || 'remote-desktop-service';
const VNC_SERVICE_PORT = process.env.VNC_SERVICE_PORT || 6901;
const VNC_PASSWORD = process.env.VNC_PASSWORD || 'bakku-the-wizard'; // Default password

// SSH service configuration
const SSH_HOST = process.env.SSH_HOST || 'remote-terminal'; // Use remote-terminal service
const SSH_PORT = process.env.SSH_PORT || 22;
const SSH_USER = process.env.SSH_USER || 'candidate';
const SSH_PASSWORD = process.env.SSH_PASSWORD || 'password';

const app = express();
const server = http.createServer(app);
const io = socketio(server);

// SSH terminal namespace
const sshIO = io.of('/ssh');

// Handle SSH connections
sshIO.on('connection', (socket) => {
    console.log('New SSH terminal connection established');
    
    let ssh = new Client();
    
    // Connect to the SSH server
    ssh.on('ready', () => {
        console.log('SSH connection established');
        
        // Create shell session
        ssh.shell((err, stream) => {
            if (err) {
                console.error('SSH shell error:', err);
                socket.emit('data', `Error: ${err.message}\r\n`);
                socket.disconnect();
                return;
            }
            
            // Handle incoming data from SSH server
            stream.on('data', (data) => {
                socket.emit('data', data.toString('utf-8'));
            });
            
            // Handle errors on stream
            stream.on('close', () => {
                console.log('SSH stream closed');
                ssh.end();
                socket.disconnect();
            });
            
            stream.on('error', (err) => {
                console.error('SSH stream error:', err);
                socket.emit('data', `Error: ${err.message}\r\n`);
            });
            
            // Handle incoming data from browser
            socket.on('data', (data) => {
                stream.write(data);
            });
            
            // Handle resize events
            socket.on('resize', (dimensions) => {
                if (dimensions && dimensions.cols && dimensions.rows) {
                    stream.setWindow(dimensions.rows, dimensions.cols, 0, 0);
                }
            });
            
            // Handle socket disconnection
            socket.on('disconnect', () => {
                console.log('Client disconnected from SSH terminal');
                stream.close();
                ssh.end();
            });
        });
    });
    
    // Handle SSH connection errors
    ssh.on('error', (err) => {
        console.error('SSH connection error:', err);
        socket.emit('data', `SSH connection error: ${err.message}\r\n`);
        socket.disconnect();
    });
    
    // Connect to SSH server
    ssh.connect({
        host: SSH_HOST,
        port: SSH_PORT,
        username: SSH_USER,
        password: SSH_PASSWORD,
        readyTimeout: 30000,
        keepaliveInterval: 10000
    });
});

// Create the public directory if it doesn't exist
const publicDir = path.join(__dirname, 'public');
if (!fs.existsSync(publicDir)) {
    fs.mkdirSync(publicDir, { recursive: true });
    console.log('Created public directory');
}

// Copy index.html to public directory if it doesn't exist
const indexHtmlSrc = path.join(__dirname, 'index.html');
const indexHtmlDest = path.join(publicDir, 'index.html');
if (fs.existsSync(indexHtmlSrc) && !fs.existsSync(indexHtmlDest)) {
    fs.copyFileSync(indexHtmlSrc, indexHtmlDest);
    console.log('Copied index.html to public directory');
}

// Enable CORS
app.use(cors());

// Serve static files from the public directory
app.use(express.static(path.join(__dirname, 'public')));

// Configure VNC proxy middleware
const vncProxyConfig = {
    target: `http://${VNC_SERVICE_HOST}:${VNC_SERVICE_PORT}`,
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

// Middleware to enhance VNC URLs with authentication if needed
app.use('/vnc-proxy', (req, res, next) => {
    // Check if the URL already has a password parameter
    if (!req.query.password) {
        // If no password provided, add default password
        console.log('Adding default VNC password to request');
        const separator = req.url.includes('?') ? '&' : '?';
        req.url = `${req.url}${separator}password=${VNC_PASSWORD}`;
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
        proxyReq.setHeader('Origin', `http://${VNC_SERVICE_HOST}:${VNC_SERVICE_PORT}`);
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

// API endpoint to get VNC server info
app.get('/api/vnc-info', (req, res) => {
    res.json({
        host: VNC_SERVICE_HOST,
        port: VNC_SERVICE_PORT,
        wsUrl: `/websockify`,
        defaultPassword: VNC_PASSWORD,
        status: 'connected'
    });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', message: 'Service is healthy' });
});

// Catch-all route to serve index.html for any other requests
app.get('*', (req, res) => {
    // Special handling for exam page
    if (req.path === '/exam') {
        res.sendFile(path.join(__dirname, 'public', 'exam.html'));
    } 
    // Special handling for results page
    else if (req.path === '/results') {
        res.sendFile(path.join(__dirname, 'public', 'results.html'));
    }
    else {
        res.sendFile(path.join(__dirname, 'public', 'index.html'));
    }
});

// Handle errors
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).sendFile(path.join(__dirname, 'public', '50x.html'));
});

// Start the server
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`VNC proxy configured to ${VNC_SERVICE_HOST}:${VNC_SERVICE_PORT}`);
    console.log(`SSH service configured to ${SSH_HOST}:${SSH_PORT}`);
}); 