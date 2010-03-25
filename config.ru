# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

require 'rack/coffee'
use Rack::Coffee, :root => "#{Rails.root}/app/scripts", :static => false

run PlexWeb::Application
