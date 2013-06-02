class Slide
class CodeSlide extends Slide
  constructor: ({@code}) ->
class TitleSlide extends Slide
  constructor: ({@title, @subtitle}) ->

slides = [
  new CodeSlide
    code: """print "I've defined a `print` function that will write to this little output box."
  print "Press ⌘↵ or ^↵ to run this code."
  print "Press ^L to clear the output."
  print "Press ^O to revert to the original code (if you make changes)."
  """
  new TitleSlide
    title: "CoffeeScript"
    subtitle: "It's like JavaScript but better"
  new CodeSlide
    code: "print 'hey there'"
  new TitleSlide
    title: "async.js"
    subtitle: "Asynchronous control flow"
  new CodeSlide
    code: "options = {port: 100}\n{port} = options\nprint port"
]

keys = { enter: 13, l: 76, o: 79 }

class View extends Backbone.View
  render: () ->
    @$el.html JST[@className.split(' ').join('-')](@model)
    return this

class TitleSlideView extends View
  className: 'title slide'
  becomeActiveSlide: ->

class CodeSlideView extends View
  className: 'code slide'
  events:
    'keyup .coffeescript': 'updateJavascript'
    'keydown .coffeescript': 'updateJavascript'
  updateJavascript: ->
    $coffeescript = @$('> .coffeescript')
    $javascript = @$('> .javascript')
    $error = @$('> .error')

    try
      js = CoffeeScript.compile $coffeescript.val(), {bare: true}
      $javascript.text js
      $error.text "okay"
      $error.removeClass 'bad'
    catch {message, location: {first_line: line}}
      $error.addClass 'bad'
      $error.text "#{message} on line #{line + 1}"

  render: ->
    super
    @revertCode()
    return this
  clearOutput: ->
    $output = @$('.output')
    $output.html('')
  runCode: ->
    $javascript = @$('.javascript')
    $output = @$('.output')
    window.uglyHackyGlobalPrintFunction = (thing) =>
      if _.isObject(thing)
        stringForm = JSON.stringify(thing)
      else
        stringForm = thing.toString()

      element = document.createElement('div')
      $(element).addClass 'printed'
      $(element).text stringForm
      $output.append element
      $output.scrollTop $output.prop('scrollHeight')
    prefix = "(function() { var print = window.uglyHackyGlobalPrintFunction; "
    postfix = "}).call(\"you think you're so clever\");"
    try
      eval [prefix, $javascript.text(), postfix].join('')
    catch ex
      element = document.createElement('div')
      $(element).addClass 'error'
      $(element).text ex.message
      $output.append element
    delete window.uglyHackyGlobalPrintFunction

  revertCode: ->
    $coffeescript = @$('.coffeescript')
    $coffeescript.val @model.code
    @updateJavascript()

  becomeActiveSlide: ->
    if !@loadedBefore
      @runCode()
      @loadedBefore = true

class DeckView extends View
  events:
    'click .next-button': 'nextSlide'
    'click .prev-button': 'prevSlide'
    'resize .slides': 'sizeChanged'
  render: ->
    if @slideViews?
      for slideView in @slideViews
        slideView.remove()

    super

    @slideViews = []
    for slide in @model.slides
      if slide instanceof TitleSlide
        @slideViews.push new TitleSlideView(model: slide)
      else if slide instanceof CodeSlide
        @slideViews.push new CodeSlideView(model: slide)
      else
        throw "i don't know what to do with that"
    $slides = @$('.slides')
    for slideView in @slideViews
      $slides.append slideView.render().el

    @gotoSlide @expectedSlideIndex, {animated: false}
    return this

  className: 'deck'
  initialize: ({@socket}) ->
    $(window).on 'resize', =>
      @gotoSlide @currentSlideIndex, {animated: false}
    $(window).on 'keydown', (e) =>
      slideView = @currentSlideView()
      if slideView not instanceof CodeSlideView
        return
      if (e.metaKey or e.ctrlKey) and e.which == keys.enter
        slideView.runCode()
      else if e.ctrlKey and e.which == keys.l
        slideView.clearOutput()
      else if e.ctrlKey and e.which == keys.o
        slideView.revertCode()
      else
        return
      e.preventDefault()

    @expectedSlideIndex = 0

    @socket.on 'changeSlide', ({index}) =>
      console.log 'slide changed'
      @expectedSlideIndex = index
      @updateButtons()

  updateButtons: ->
    $prevButton = @$('.prev-button').removeClass('expected')
    $nextButton = @$('.next-button').removeClass('expected')
    if @expectedSlideIndex < @currentSlideIndex
      $prevButton.addClass 'expected'
    else if @expectedSlideIndex > @currentSlideIndex
      $nextButton.addClass 'expected'

  nextSlide: ->
    @gotoSlide @currentSlideIndex + 1
  prevSlide: ->
    @gotoSlide @currentSlideIndex - 1
  gotoSlide: (slideIndex, {animated} = {animated: true}) ->
    slideIndex = if slideIndex < 0 then 0 else slideIndex
    slideIndex = if slideIndex >= @model.slides.length then @model.slides.length - 1 else slideIndex

    $slides = @$('.slides')

    scrollLeft = slideIndex * ($slides.outerWidth() - parseInt($slides.css('padding-left'), 10))
    if animated
      $slides.animate {scrollLeft}, {queue: false}
    else
      $slides.scrollLeft scrollLeft
    if @currentSlideIndex != slideIndex
      $(':focus').blur()
      @currentSlideIndex = slideIndex
      @currentSlideView().becomeActiveSlide()
    @updateButtons()
    @socket.emit 'slideChanged', {index: @currentSlideIndex}
  currentSlideView: ->
    return @slideViews[@currentSlideIndex]


$ ->
  socket = io.connect('/')

  deckView = new DeckView {model: {slides}, socket}
  document.body.appendChild deckView.render().el
