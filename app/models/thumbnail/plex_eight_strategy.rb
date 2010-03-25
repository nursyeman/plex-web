class Thumbnail::PlexEightStrategy
  def initialize(path)
    @path = path
  end

  def get_thumbnail(movie, type=:poster)
    case type
    when :poster
      crc = crc32(movie)
      "%s/%c/%s.tbn" % [@path, crc[0], crc]
    when :fanart
      "%s/%s.tbn" % [File.join(@path, 'Fanart'), crc32(movie)]
    end
  end

  private

  def crc32(movie)
    sprintf("%08x", Crc32.crc32(movie.file.to_s.downcase))
  end
end