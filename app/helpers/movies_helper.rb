module MoviesHelper
  def movie_data_for_view(movie)
    {
      :title => movie.title,
      :posters => {
        :small => {:url => movie_poster_url(movie, :small), :width => Thumbnail::SIZES[:small]},
        :default => {:url => movie_poster_url(movie, :default), :width => Thumbnail::SIZES[:default]},
      },
      :fanarts => {:default => {:url => movie_fanart_url(movie, :default)}},
    }
  end
end
