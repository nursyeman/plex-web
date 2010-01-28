class Thumbnail::PlexEightStrategy
  THUMBS_DIR = File.expand_path("~/Library/Application Support/Plex/userdata/Thumbnails/Video").freeze

  def get_thumbnail(movie)
    crc = crc32(movie)
    hex = sprintf("%08x", crc)
    return sprintf("%s/%c/%s.tbn", THUMBS_DIR, hex[0], hex)
  end

  private

  def crc32(movie)
    Crc32.crc32(movie.file.to_s.downcase)
  end
end