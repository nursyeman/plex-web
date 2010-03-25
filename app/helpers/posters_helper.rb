module PostersHelper
  def small_poster(movie)
    image_tag(movie_poster_url(movie, :small), :alt => movie.title, :width => Thumbnail::SIZES[:small])
  end

  def large_poster(movie)
    image_tag(movie_poster_url(movie, :large), :alt => movie.title, :width => Thumbnail::SIZES[:large])
  end

  def full_poster(movie)
    image_tag(movie_poster_url(movie, :default), :alt => movie.title, :width => Thumbnail::SIZES[:default])
  end

  def small_fanart(movie)
    image_tag(movie_fanart_url(movie, :small), :alt => movie.title, :width => Thumbnail::SIZES[:small])
  end

  def large_fanart(movie)
    image_tag(movie_fanart_url(movie, :large), :alt => movie.title, :width => Thumbnail::SIZES[:large])
  end

  def full_fanart(movie)
    image_tag(movie_fanart_url(movie, :default), :alt => movie.title, :width => Thumbnail::SIZES[:default])
  end
end
