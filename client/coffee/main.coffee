slide1 = 
  text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent congue imperdiet nisl ac sagittis. Morbi molestie aliquam tincidunt. Phasellus quis urna at elit adipiscing viverra eget sed odio. Sed sollicitudin viverra sollicitudin. Fusce at augue arcu, eu dignissim velit. Nam leo massa, interdum ut placerat vitae, volutpat et risus. Integer eleifend ante quis arcu cursus feugiat sit amet eget metus. Pellentesque mollis urna sit amet arcu vulputate in feugiat sapien placerat. Suspendisse fermentum vestibulum justo, et vestibulum ante tempus et. Curabitur in magna justo, vel semper nibh. Donec scelerisque felis eget libero convallis tincidunt. Morbi ultricies hendrerit facilisis. In hendrerit blandit nibh, a viverra lectus aliquet quis. Ut rutrum sapien id risus mattis non mollis elit condimentum. Nulla ac tortor dui, rhoncus gravida magna. Sed a sapien in leo feugiat gravida quis et massa."
  code: "x = 10"
slide2 =
  text: "Nunc vulputate, lacus eu gravida mattis, erat magna blandit libero, nec volutpat metus nisl eget ante. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam rutrum molestie euismod. Donec justo velit, cursus quis dignissim non, elementum sit amet justo. Proin vestibulum pulvinar erat, ut auctor felis lacinia et. Suspendisse nisl lectus, fringilla nec dignissim porttitor, tincidunt non ante. Integer quis metus tellus, id mollis urna. Fusce augue arcu, sagittis nec egestas non, blandit vitae risus. Maecenas vehicula vestibulum placerat. Donec mattis ultricies lorem, molestie venenatis ante auctor ac. Integer tortor mauris, congue semper venenatis ac, ultricies in arcu. Praesent eget risus consequat est placerat laoreet eu sed nibh. Proin facilisis, ante gravida iaculis ornare, quam dolor mattis nulla, sit amet viverra tortor leo semper purus. Curabitur ac dui nec velit iaculis consequat quis et lacus. Fusce vulputate suscipit dolor sed cursus."
  code: "x = ->\ny = () ->"
slide3 =
  text: "Fusce vel leo eu lacus lobortis varius ut a justo. In hac habitasse platea dictumst. Sed luctus, leo at gravida pharetra, lorem lectus lobortis diam, vel tempor ante metus vitae lectus. Nulla erat nibh, pellentesque vel gravida vitae, sollicitudin id lacus. Mauris volutpat tincidunt lorem at malesuada. Aenean vitae dignissim ligula. Praesent viverra metus erat. Nullam luctus, turpis in suscipit aliquam, elit nulla facilisis tortor, eu ultrices mauris elit a enim. Maecenas et erat diam. Nulla ultrices eleifend est. Sed dignissim blandit dui at suscipit. Cras mattis hendrerit tellus eget sagittis. Phasellus sit amet magna eget enim auctor feugiat. Cras quis enim urna, id rhoncus elit. Fusce accumsan libero sed velit tempus a condimentum odio tempus. Maecenas laoreet aliquam elit, a volutpat elit adipiscing eget."
  code: "options = {port: 100}\n{port} = options"

class View extends Backbone.View
  render: () ->
    @$el.html JST[@className](@model)
    return this

class SlideView extends View
  className: 'slide'
  events:
    'keyup .coffeescript': 'updateJavascript'
    'keydown .coffeescript': 'updateJavascript'
  updateJavascript: ->
    $coffeescript = @$('.coffeescript')
    $javascript = @$('.javascript')
    $error = @$('.error')

    try
      js = CoffeeScript.compile $coffeescript.val(), {bare: true}
      $javascript.text js
      $error.text "okay"
      $error.removeClass 'bad'
    catch {message, location: {first_line: line}}
      $error.addClass 'bad'
      $error.text "#{message} on line #{line}"

  render: ->
    super
    @updateJavascript()
    return this

class DeckView extends View
  render: ->
    if @slideViews?
      for slideView in @slideViews
        slideView.remove()

    super

    @slideViews = (new SlideView({model}) for model in @model.slides)
    $slides = @$('.slides')
    for slideView in @slideViews
      $slides.append slideView.render().el
    return this
    
  className: 'deck'

$ ->
  deckView = new DeckView(model: {slides: [slide1, slide2, slide3]})
  document.body.appendChild deckView.render().el

console.log 'success'

socket = io.connect('/')
socket.on 'change', (data) ->
  console.log data
