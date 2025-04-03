const express = require('express');
const http = require('http');
const WebSocket = require('ws');

// Create an Express app and a server
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Serve the static HTML page (index.html)
app.use(express.static('public'));

// Handle WebSocket connections
let clients = [];

wss.on('connection', (ws) => {
    // Add new client
    clients.push(ws);
    console.log("New client connected");

    // When a message is received from a client (a move is made)
    ws.on('message', (message) => {
        console.log('Received message:', message);
        
        // Broadcast the move to all other clients
        clients.forEach(client => {
            if (client !== ws) {
                client.send(message);
            }
        });
    });

    // Remove client when they disconnect
    ws.on('close', () => {
        clients = clients.filter(client => client !== ws);
        console.log("Client disconnected");
    });
});

// Start the server
server.listen(8080, () => {
    console.log('Server running on http://localhost:8080');
});
