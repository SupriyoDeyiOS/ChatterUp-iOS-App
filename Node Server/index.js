const express = require('express');
const app = express();
const http = require('http');
const path = require('path');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);

app.use(express.static(path.resolve("./Frontend")));

app.get('/', (req, res) => {
    res.sendFile("/Frontend" + '/index.html');
  });

io.on('connection', (socket) => {
    //when connection established
  console.log('New user connected', socket.id);

  //when connection disconnected
  socket.on('disconnect', () => {
    console.log('user disconnected', socket.id);
  });

  //received a new message
  socket.on('ChatterUp-message', (msg) => {
    console.log('message: ' + msg);
    socket.broadcast.emit('ChatterUp-message', msg); //sent the message to all connected users except the sender
    //io.emit('ChatterUp-message', msg); //sent the message to all connected users
  });

});

server.listen(8000, () => {
  console.log('listening on :8000');
});