jQuery ($) ->
  # window: this
  header: $'h1'
  body: $'body'
  container: $'#container'
  dimmer: $'#dimmer'
  backgroundImage: $'#background-image'

  setBackground: (url) ->
    imageLoader: $(new Image())

    resize: ->
      imageWidth: imageLoader.attr('width')
      imageHeight: imageLoader.attr('height')
      windowWidth: window.innerWidth || $(window).width()
      windowHeight: window.innerHeight || $(window).height()

      # try fixing the height to window height
      height: windowHeight
      width: imageWidth * height / imageHeight
      if width < windowWidth
        # nope, fix the width to window width
        width: windowWidth
        height: imageHeight * width / imageWidth

      backgroundImage.width(width).height(height)

    imageLoader.one 'load', ->
      # hide it
      dimmer.css {
        opacity: 0
      }

      # use the pre-loaded image
      backgroundImage.attr 'src', url

      # set width & height
      resize()

      # show it
      dimmer.animate {
        opacity: 0.5
      }

    imageLoader.attr 'src', url
    $(window).bind 'resize', resize

  maximize: (element, keepMaximized) ->
    max: ->
      element
        .width(windowWidth())
        .height(windowHeight())

    max()
    $(window).bind 'resize', max if keepMaximized

  keepMaximized: (element) -> maximize element, true

  windowWidth: -> window.innerWidth || $(window).width()
  windowHeight: -> window.innerHeight || $(window).height()

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
        console.log(movie)
        $("<a href='#' class='movie'><img src='${movie.posters.small.url}' width='${movie.posters.small.width}'/></a>").click ->
          $('.movie').hide()
          setBackground movie.fanarts['default'].url
          setTitle movie.title
    $(movies).appendTo container

  keepMaximized container.add(dimmer)
  maximize backgroundImage
