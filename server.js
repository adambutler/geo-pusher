var express = require("express");
var Pusher = require("pusher");
var bodyParser = require("body-parser");
var env = require("node-env-file");

var app = express();

app.use(bodyParser.urlencoded());

try {
  env(__dirname + "/.env");
} catch (_error) {
  error = _error;
  console.log(error);
}

var pusher = new Pusher({
  appId: process.env.PUSHER_APP_ID,
  key: process.env.PUSHER_APP_KEY,
  secret: process.env.PUSHER_APP_SECRET
});

app.use('/', express["static"]('dist'));

app.post("/pusher/auth", function(req, res) {
  var socketId = req.body.socket_id;
  var channel = req.body.channel_name;
  var auth = pusher.authenticate(socketId, channel);
  res.send(auth);
});

var port = process.env.PORT || 5000;

app.listen(port);
