class ImageLoader
  load: (url, callback) ->
    img: new Image()
    img.onload: =>
      callback(new LoadedImage(url, new Size(img.width, img.height)))
    img.src = url

ImageLoader.load: (url, callback) ->
  (new ImageLoader()).load url, callback

class LoadedImage
  constructor: (url, size) ->
    @url: url
    @size: size
    @width: size.width
    @height: size.height

class View
  constructor: (element) ->
    @element: element
    @bind 'keydown', (event) => @onKeyPress event

  onKeyPress: (event) ->
    console.log event.which
    switch event.which
      when 27
        event.preventDefault()
        @trigger 'cancel'

  bind: (name, callback) ->
    @element.bind name, callback

  trigger: (name, data) ->
    @element.trigger name, data

  css: ->
    @element.css.apply(@element, arguments)

  animate: ->
    @element.animate.apply(@element, arguments)

  size: ->
    new Size(@element.width(), @element.height())

  setSize: (size) ->
    @element.width(size.width).height(size.height)

  show: ->
    @element.show.apply(@element, arguments)

  hide: ->
    @element.hide.apply(@element, arguments)

  maximize: (size) ->
    @setSize size || Viewport.size()

  keepMaximized: (size) ->
    Viewport.bind 'resize', =>
      @maximize size

  remove: ->
    @element.remove()
    @element: null

Viewport: new View($(window))


class Wallpaper extends View
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

  clear: ->
    @hide()
    @load ''

  onload: (loadedImage) ->
    return unless loadedImage.url is @url
    @trigger 'imageWillLoad'
    @loadedImage: loadedImage
    @element.attr 'src', loadedImage.url
    @maximize()
    @show()
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

Page: new View($(document))

Page.pushView: (view) ->
  @stack ||= []
  _.invoke @stack, 'hide'
  @stack.push view
  view.element.appendTo($('body'))
  view.show()

Page.popView: ->
  @stack ||= []
  return if @stack.length == 1
  view: @stack.pop()
  view.remove()
  Page.pushView @stack.pop()

Page.bind 'cancel', ->
  Page.popView()

class MovieTileList extends View
  tiles: null

  constructor: ->
    super $('<div></div>')

  displayTiles: (tiles) ->
    @hide()
    _.invoke(@tiles, 'remove') if @tiles
    @tiles: tiles
    $(_.pluck(tiles, 'element')).appendTo(@element)
    @show()

  show: ->
    Page.wallpaper.clear()
    super()

class MovieTile extends View
  movie: null

  constructor: ->
    super $('<div class="tile"><img /></div>')
    @image: @element.find 'img'
    @bind 'click', =>
      Page.pushView new MovieDetailView(@movie)

  setMovie: (movie) ->
    @hide()
    @movie: movie
    movie.downloadPoster 'small', (loadedImage) =>
      @image.attr 'src', loadedImage.url
      @css {
        'margin': '5px'
        'float': 'left'
      }
      @show()

class Movie
  data: null

  constructor: (data) ->
    @setData data if data

  setData: (data) ->
    @data: data

  fanartURL: (size) ->
    fanart: @data.fanarts[size || 'default'] if @data
    fanart.url if fanart

  posterURL: (size) ->
    poster: @data.posters[size || 'default'] if @data
    poster.url if poster

  downloadPoster: (size, callback) ->
    ImageLoader.load @posterURL(size), callback

class MovieDetailView extends View
  movie: null

  constructor: (movie) ->
    super $('<div></div>')
    @movie: movie

  show: ->
    Page.wallpaper.load @movie.fanartURL()
    super()

jQuery ($) ->
  Page.wallpaper: new Wallpaper($('body > .wallpaper'))

  Page.wallpaper.bind 'imageWillLoad', ->
    Page.wallpaper.css {
      opacity: 1
    }

  Page.wallpaper.bind 'load', ->
    Page.wallpaper.animate {
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
    tileList: new MovieTileList()
    tiles:
      _.map data, (datum) ->
        tile: new MovieTile()
        tile.setMovie(new Movie(datum))
        return tile
    tileList.displayTiles tiles
    Page.pushView tileList
