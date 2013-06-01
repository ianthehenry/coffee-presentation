class Slide
class CodeSlide extends Slide
  constructor: ({@text, @code}) ->
class TitleSlide extends Slide
  constructor: ({@title, @subtitle}) ->

slides = [
  new TitleSlide 
    title: "CoffeeScript"
    subtitle: "It's like JavaScript but better"
  new CodeSlide
    text: "This is all interactive so you can play with it as we go."
    code: """print "I've defined a `print` function that will write to this little output box."
  print "Press ⌘↵ or ^↵ to run this code."
  print "Press ^L to clear the output."
  print "Press ^O to revert to the original code (if you make changes)."
  """
  new CodeSlide
    text: "Nunc vulputate, lacus eu gravida mattis, erat magna blandit libero, nec volutpat metus nisl eget ante. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam rutrum molestie euismod. Donec justo velit, cursus quis dignissim non, elementum sit amet justo. Proin vestibulum pulvinar erat, ut auctor felis lacinia et. Suspendisse nisl lectus, fringilla nec dignissim porttitor, tincidunt non ante. Integer quis metus tellus, id mollis urna. Fusce augue arcu, sagittis nec egestas non, blandit vitae risus. Maecenas vehicula vestibulum placerat. Donec mattis ultricies lorem, molestie venenatis ante auctor ac. Integer tortor mauris, congue semper venenatis ac, ultricies in arcu. Praesent eget risus consequat est placerat laoreet eu sed nibh. Proin facilisis, ante gravida iaculis ornare, quam dolor mattis nulla, sit amet viverra tortor leo semper purus. Curabitur ac dui nec velit iaculis consequat quis et lacus. Fusce vulputate suscipit dolor sed cursus."
    code: "print 'hey there'"
  new TitleSlide
    title: "async.js"
    subtitle: "Asynchronous control flow"
  new CodeSlide
    text: "Fusce vel leo eu lacus lobortis varius ut a justo. In hac habitasse platea dictumst. Sed luctus, leo at gravida pharetra, lorem lectus lobortis diam, vel tempor ante metus vitae lectus. Nulla erat nibh, pellentesque vel gravida vitae, sollicitudin id lacus. Mauris volutpat tincidunt lorem at malesuada. Aenean vitae dignissim ligula. Praesent viverra metus erat. Nullam luctus, turpis in suscipit aliquam, elit nulla facilisis tortor, eu ultrices mauris elit a enim. Maecenas et erat diam. Nulla ultrices eleifend est. Sed dignissim blandit dui at suscipit. Cras mattis hendrerit tellus eget sagittis. Phasellus sit amet magna eget enim auctor feugiat. Cras quis enim urna, id rhoncus elit. Fusce accumsan libero sed velit tempus a condimentum odio tempus. Maecenas laoreet aliquam elit, a volutpat elit adipiscing eget."
    code: "options = {port: 100}\n{port} = options\nprint port"
]

keys = { enter: 13, l: 76, o: 79 }

class View extends Backbone.View
  render: () ->
    @$el.html JST[@className](@model)
    return this

class TitleSlideView extends View
  className: 'title-slide'
  becomeActiveSlide: ->

class CodeSlideView extends View
  className: 'code-slide'
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

    @gotoSlide 0, {animated: false}
    return this
    
  className: 'deck'
  initialize: ->
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
      @currentSlideIndex = slideIndex
      @currentSlideView().becomeActiveSlide()
  currentSlideView: ->
    return @slideViews[@currentSlideIndex]


$ ->
  deckView = new DeckView(model: {slides})
  document.body.appendChild deckView.render().el

socket = io.connect('/')
socket.on 'change', (data) ->
  console.log data
