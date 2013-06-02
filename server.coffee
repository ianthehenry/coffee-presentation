args     = require './args.coffee'
express  = require 'express'
http     = require 'http'
app      = express()
server   = http.createServer(app)
io       = require('socket.io').listen(server)

app.set 'port', args.port
app.use express.logger('dev')
app.use express.compress()
app.use express.bodyParser()
app.use '/static', express.static('client/static')

if app.get('env') == 'development'
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.sendfile "client/index.html"

server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"

io.sockets.on 'connection', (socket) ->
  socket.on 'slideChanged', ({index}) ->
    console.log "now on slide #{index}"
  setTimeout ->
    socket.emit 'changeSlide', { index: 2 }
  , 1000
