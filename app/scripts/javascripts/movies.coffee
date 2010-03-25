class ImageLoader
  load: (url, callback) ->
    img: new Image()
    img.onload: =>
      callback(new LoadedImage(url, new Size(img.width, img.height)))
    img.src = url

class LoadedImage
  constructor: (url, size) ->
    @url: url
    @size: size
    @width: size.width
    @height: size.height

Viewport: {
  element: $(window)

  size: ->
    Size.sizeForElement @element

  bind: (name, callback) ->
    @element.bind(name, callback)
}

class View
  constructor: (element) ->
    @element: element

  bind: (name, callback) ->
    @element.bind name, callback

  trigger: (name, data) ->
    @element.trigger name, data

  css: ->
    @element.css.apply(@element, arguments)

  animate: ->
    @element.animate.apply(@element, arguments)

  maximize: (keepMaximized, size) ->
    max: =>
      Size.setSizeForElement @element, size || Viewport.size()

    max()
    Viewport.bind 'resize', max if keepMaximized

  keepMaximized: -> @maximize true

class BackgroundImage extends View
  url: null
  loadedImage: null

  constructor: (element) ->
    super element
    @imageLoader: new ImageLoader()
    @keepMaximized()

  load: (url) ->
    @url: url
    @imageLoader.load url, (loadedImage) =>
      @onload loadedImage

  onload: (loadedImage) ->
    return unless loadedImage.url is @url
    @trigger 'imageWillLoad'
    @loadedImage: loadedImage
    @element.attr 'src', loadedImage.url
    @maximize()
    @trigger 'load'

  maximize: ->
    return unless @loadedImage
    super @loadedImage.size.fill(Viewport.size())

class Size
  width: 0
  height: 0

  constructor: (width, height) ->
    @width: width if width?
    @height: height if height?

  # Returns a `Size` scaled preserving aspect ratio to fill `size`.
  # The returned `Size` will either be identical to `size` or have
  # the same width with a greater height or the same height with a
  # greater width.
  fill: (size) ->
    # try scaling to the same height
    height: size.height
    width: @width * height / @height
    if width < size.width
      # nope, we need to scale to the same width
      width: size.width
      height: @height * width / @width

    return new Size(width, height)

Size.zero: ->
  new Size(0, 0)

Size.sizeForElement: (element) ->
  new Size($(element).width(), $(element).height())

Size.setSizeForElement: (element, size) ->
  $(element).width(size.width).height(size.height)

Size.sizeForViewport: ->
  Size.sizeForElement window

jQuery ($) ->
  # window: this
  header: $'h1'
  body: $'body'
  container: new View($'#container')
  dimmer: new View($'#dimmer')
  backgroundImage: new BackgroundImage($'#background-image')

  backgroundImage.bind 'imageWillLoad', ->
    dimmer.css {
      opacity: 0
    }

  backgroundImage.bind 'load', ->
    dimmer.animate {
      opacity: 0.5
    }


  setTitle: (title) ->
    header.text title

  api: {
    movies: (callback) ->
      $.ajax {
        type: 'GET'
        url: '/movies'
        dataType: 'json'
        success: callback
      }
  }

  api.movies (data) ->
    movies:
      _.map data, (movie) ->
        $("<a href='#' class='movie'><img src='${movie.posters.small.url}' width='${movie.posters.small.width}'/></a>").click ->
          $('.movie').hide()
          backgroundImage.load movie.fanarts['default'].url
          setTitle movie.title
    $(movies).appendTo container.element

  container.keepMaximized()
  dimmer.keepMaximized()