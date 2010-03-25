set_thumbnail_strategy = proc do
  thumbs_dir = File.expand_path("~/Library/Application Support/Plex/userdata/Thumbnails/Video")
  Thumbnail.strategy = Thumbnail::PlexEightStrategy.new(thumbs_dir)
end

set_thumbnail_strategy.call
ActionDispatch::Callbacks.to_prepare(&set_thumbnail_strategy) if Rails.env.development?