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

index = (req, res) ->
  res.sendfile "client/index.html"

app.get '/', index
app.get '/slides/:index', index

server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"

masterSocket = null
expectedSlideIndex = 1

io.sockets.on 'connection', (socket) ->
  socket.emit 'changeSlide', {index: expectedSlideIndex}
  socket.on 'slideChanged', ({index}) ->
    if socket == masterSocket
      expectedSlideIndex = index
      socket.broadcast.emit 'changeSlide', {index}
      console.log "master slide set to #{index}"
    else
      console.log "#{socket.id} now on slide #{index}"

  socket.on 'disconnect', ->
    if socket == masterSocket
      console.log "master disconnected"
      masterSocket = null
    else
      console.log "#{socket.id} disconnected"

  socket.on 'requestMaster', ->
    if masterSocket?
      if masterSocket == socket
        console.log "you are already the master"
      else
        console.log "no, we already have one"
    else
      console.log "#{socket.id} is now the master"
      masterSocket = socket
