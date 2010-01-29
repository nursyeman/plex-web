module ThumbnailsHelper
  def small_thumbnail(movie)
    image_tag(movie_thumbnail_url(movie, :small), :alt => movie.title, :width => Thumbnail::SIZES[:small])
  end

  def large_thumbnail(movie)
    image_tag(movie_thumbnail_url(movie, :large), :alt => movie.title, :width => Thumbnail::SIZES[:large])
  end

  def full_thumbnail(movie)
    image_tag(movie_thumbnail_url(movie, :default), :alt => movie.title, :width => Thumbnail::SIZES[:default])
  end
end
