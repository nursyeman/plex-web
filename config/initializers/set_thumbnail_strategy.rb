ActionController::Dispatcher.to_prepare do
  Thumbnail.strategy ||= Thumbnail::PlexEightStrategy.new
end