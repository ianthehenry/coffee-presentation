args     = require './args.coffee'
express  = require 'express'
http     = require 'http'
app      = express()
server   = http.createServer(app)
io       = require('socket.io').listen(server)
fs       = require 'fs'

deck = fs.readFileSync 'deck.coffee', 'utf8'
slides = []

# The motive for this format was that it would be valid markdown and valid coffeescript.
# But then I made it valid neither. So, just, yeah. This prevented me from having
# comments in my code sample. Whatever.
for line in deck.split('\n')
  if line[0...2] == '##'
    slides.push { title: line[2...].trim(), codeLines: [] }
  else if line[0] == '#'
    slides.push {title: line[1...].trim() }
  else
    lastSlide = slides[slides.length - 1]
    if 'codeLines' of lastSlide
      lastSlide.codeLines.push line
    else
      if line.length > 0
        lastSlide.subtitle = line

for slide in slides
  if 'codeLines' of slide
    slide.code = slide.codeLines.join('\n').trim()
    delete slide.codeLines

cachedDeck = "window.slides = #{ JSON.stringify(slides) };"

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
app.get '/deck.js', (req, res) ->
   # dear interns: don't write code like this
  res.setHeader 'Content-Type', 'text/javascript'
  res.end cachedDeck
app.get '/slides/:index', index

server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"

# fuck yeah global state
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
