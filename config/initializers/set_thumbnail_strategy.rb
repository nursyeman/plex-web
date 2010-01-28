ActionController::Dispatcher.to_prepare do
  Movie.thumbnail_strategy ||= Thumbnail::PlexEightStrategy.new
end