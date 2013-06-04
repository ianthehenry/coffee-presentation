keys =
  enter: 13
  escape: 27
  left: 37
  right: 39
  o: 79

class View extends Backbone.View
  render: () ->
    @$el.html JST[@className.split(' ').join('-')](@model)
    return this

class TitleSlideView extends View
  className: 'title slide'
  becomeActiveSlide: ->
  keydown: ({which, shiftKey, metaKey}) ->
    return false

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

  keydown: ({which, ctrlKey, metaKey}) ->
    if (metaKey or ctrlKey) and which == keys.enter
      @clearOutput()
      @runCode()
    else if ctrlKey and which == keys.o
      @revertCode()
    else if which == keys.escape
      $(':focus').blur()
    else
      return false
    return true

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
    window.uglyHackyGlobalPrintFunction = (things...) =>
      element = document.createElement('div')
      $(element).addClass 'printed'
      $(element).text ((if _.isString(thing) then thing else (if _.isUndefined(thing) then "undefined" else JSON.stringify(thing))) for thing in things).join('')
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
      if 'code' of slide
        @slideViews.push new CodeSlideView(model: slide)
      else
        @slideViews.push new TitleSlideView(model: slide)
    $slides = @$('.slides')
    for slideView in @slideViews
      $slides.append slideView.render().el

    @gotoSlide @currentSlideIndex, {animated: false}
    return this

  className: 'deck'
  initialize: ({@socket, @router, @currentSlideIndex}) ->
    $(window).on 'resize', =>
      @gotoSlide @currentSlideIndex, {animated: false}
    $(window).on 'keydown', (e) =>
      isInInputField = $(':focus').is('textarea, input')
      switch e.which
        when keys.left
          if isInInputField
            return
          else
            @prevSlide()
        when keys.right
          if isInInputField
            return
          else
            @nextSlide()
        else
          if not @currentSlideView().keydown(e)
            return
      e.preventDefault()

    @socket.on 'changeSlide', ({index}) =>
      @expectedSlideIndex = index
      @updateButtons()

    @router.on 'gotoSlide', (index) ->
      @gotoSlide index

    if !_.isNumber(@currentSlideIndex) or @currentSlideIndex < 0
      @currentSlideIndex = 1
    else if @currentSlideIndex >= @model.length
      @currentSlideIndex = @model.length - 1

  updateButtons: ->
    $prevButton = @$('.prev-button').removeClass('expected')
    $nextButton = @$('.next-button').removeClass('expected')
    if not @expectedSlideIndex?
      return
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
      $slides.animate {scrollLeft}, {queue: false, duration: 250}
    else
      $slides.scrollLeft scrollLeft
    if @currentSlideIndex != slideIndex
      $(':focus').blur()
      @currentSlideIndex = slideIndex
      @socket.emit 'slideChanged', {index: @currentSlideIndex}
      @router.navigate("/slides/#{@currentSlideIndex}")
    @currentSlideView().becomeActiveSlide()
    @updateButtons()
  currentSlideView: ->
    return @slideViews[@currentSlideIndex]

initialPage = 1
class Router extends Backbone.Router
  routes:
    'slides/:index': 'gotoSlide'
  gotoSlide: (index) ->
    initialPage = parseInt(index, 10)
router = new Router()
Backbone.history.start {pushState: true}

$ ->
  socket = io.connect('/')
  window.requestMaster = ->
    socket.emit 'requestMaster'

  deckView = new DeckView {model: {slides}, socket, router, currentSlideIndex: initialPage}
  document.body.appendChild deckView.el
  deckView.render()
