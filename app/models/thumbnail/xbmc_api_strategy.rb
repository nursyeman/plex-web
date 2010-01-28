class Thumbnail::XbmcApiStrategy
  def get_thumbnail(movie)
    thumbnail = plex_details(movie.file)['Thumb']
    return nil if thumbnail == '[None]'
    thumbnail
  end

private

  def plex_details(file)
    plex.get_movie_details(file.to_s)
  end

  def plex
    @plex ||= Plex.new
  end
end