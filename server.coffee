express = require("express")
Pusher = require("pusher")
bodyParser = require("body-parser")
env    = require "node-env-file"

app = express()
app.use bodyParser.urlencoded()

try
  env "#{__dirname}/.env"
catch error
  console.log error

pusher = new Pusher(
  appId: process.env.PUSHER_APP_ID
  key: process.env.PUSHER_APP_KEY
  secret: process.env.PUSHER_APP_SECRET
)

app.post "/pusher/auth", (req, res) ->
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Headers', 'Content-Type')
  socketId = req.body.socket_id
  channel = req.body.channel_name
  auth = pusher.authenticate(socketId, channel)
  res.send auth
  return

port = process.env.PORT or 5000
app.listen port
