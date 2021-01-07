var express = require('express');
var app = express();
var server  = require('http').Server(app);
var io      = require('socket.io')(server);
var redis   = require('redis').createClient();
var port    = 8181;

redis.subscribe('new_message_counter');
redis.subscribe('customer_chat');
redis.subscribe('message_chat');
redis.subscribe('customer_facebook_chat');
redis.subscribe('message_facebook_chat');
redis.subscribe('agent_assignment');

redis.on("subscribe", function(channel) {
  console.log("Subscribed to " + channel);
});

server.listen(port, function () {
  console.log('Server listening at port %d', port);
});

io.on('connection', function (socket) {
  console.log('a user connected');

  socket.on('disconnect', function(){
    console.log('user disconnected');
    socket.leave(socket.room);
  });

  socket.on('create_room', function(room) {
    socket.room = room;
    socket.join(room);
  });
});

redis.on('message', function(channel, data) {
  data = JSON.parse(data);
  io.in(data['room']).emit(channel, data);
});
