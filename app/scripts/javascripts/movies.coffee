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

  width: ->
    @element.width()

  height: ->
    @element.height()

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


class ImageView extends View
  url: null
  loadedImage: null

  constructor: (element) ->
    super element
    @imageLoader: new ImageLoader()

  load: (url) ->
    @url: url
    @imageLoader.load url, (loadedImage) =>
      @onload loadedImage

  clear: ->
    @hide()
    @load ''

  onload: (loadedImage) ->
    return unless loadedImage.url is @url
    @loadedImage: loadedImage
    @trigger 'imageWillLoad'
    @element.attr 'src', loadedImage.url
    @show()
    @trigger 'load'

class Wallpaper extends ImageView
  constructor: (element) ->
    super element
    @keepMaximized()
    @bind 'imageWillLoad', =>
      @maximize()

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

class Page extends View
  stack: null

  constructor: ->
    @stack: []
    super $(document)

  pushView: (view) ->
    @saveCurrentState()

    top: @topView()
    top.hide() if top

    @stack.push {
      view: view
    }

    view.element.appendTo($('body'))
    view.show()

  popView: ->
    return if @stack.length == 1

    state: @stack.pop()
    state.view.remove()

    top: @topView()
    top.show() if top

    @restoreCurrentState()

  topView: ->
    state: @topViewState()
    state && state.view

  topViewState: ->
    @stack && @stack[@stack.length-1]

  saveCurrentState: ->
    state: @topViewState()
    if state
      state.scrollX: window.scrollX
      state.scrollY: window.scrollY

  restoreCurrentState: ->
    state: @topViewState()
    if state
      window.scrollTo state.scrollX, state.scrollY

page: new Page()

page.bind 'cancel', ->
  page.popView()

class MovieTileList extends View
  tiles: null

  constructor: ->
    super $('<div class="MovieTileList"></div>')

  displayTiles: (tiles) ->
    @hide()
    _.invoke(@tiles, 'remove') if @tiles
    @tiles: tiles
    $(_.pluck(tiles, 'element')).appendTo(@element)
    @show()

  show: ->
    page.wallpaper.clear()
    super()

class MovieTile extends View
  movie: null

  constructor: ->
    super $('<div class="MovieTile"><img /></div>')
    @image: @element.find 'img'
    @bind 'click', =>
      page.pushView new MovieDetailView(@movie)

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

class Label extends View
  ellipses: '…'
  _text: null

  constructor: (element) ->
    super element
    @text: element.text()

  maxwidth: ->
    @maxwidth

  setMaxwidth: (maxwidth) ->
    @maxwidth: maxwidth
    @redraw()

  text: ->
    @_text

  setText: (text) ->
    @_text: text
    @redraw()

  redraw: ->
    @element.text @_text
    return unless @maxwidth? and @_text?
    return if @element.width() <= @maxwidth

    # test sizes on a copy copy to prevent reflows
    copy: @element.clone()
    copy.hide().insertAfter(@element)

    fullText: @_text

    for i in [fullText.length-@ellipses.length-1..0]
      text: fullText.substring(0, i) + @ellipses
      copy.text(text)
      console.log text, copy.width(), @maxwidth
      if copy.width() <= @maxwidth
        @element.text text
        break

    # clean up the copy
    copy.remove()

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

  title: ->
    @data.title

  description: ->
    @data.description

class MovieDetailView extends View
  movie: null

  constructor: (movie) ->
    super $('
      <div class="MovieDetailView">
        <h1></h1>
        <img class="MoviePoster" />
        <p class="MovieDescription"></p>
      </div>')

    @h1:          new Label(@element.find 'h1')
    @poster:      new ImageView(@element.find '.MoviePoster')
    @description: @element.find '.MovieDescription'
    @movie:       movie

    @onresize()
    Viewport.bind 'resize', => @onresize()

  show: ->
    @h1.setText @movie.title()
    page.wallpaper.load @movie.fanartURL()
    @poster.load @movie.posterURL()
    @description.text @movie.description()
    super()

  onresize: ->
    # 20 margin + 300 poster + 20 margin + h1.width + 20 margin = page.width
    @h1.setMaxwidth page.width() - 360

jQuery ($) ->
  page.wallpaper: new Wallpaper($('body > .Wallpaper'))

  setTitle: (title) ->
    header.text title

  api: {
    movies: (callback) ->
      $.ajax {
        type: 'GET'
        url: '/movies.json'
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
    page.pushView tileList
