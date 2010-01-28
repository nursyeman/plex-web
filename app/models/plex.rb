require 'restclient'
require 'nokogiri'
require 'cgi'

class Plex
  def run(command, *args)
    api["?command=#{CGI.escape("#{command}(#{args.join(';')})")}"].get
  end

  def get_movie_details(path)
    details = run :GetMovieDetails, path
    doc = Nokogiri::HTML.parse(details)
    doc.css('li').inject({}) do |result, li|
      key, value = li.content.split(':', 2)
      result.merge(key.chomp => value.chomp)
    end
  end

  protected

  def api
    @api ||= RestClient::Resource.new('http://localhost:9999/xbmcCmds/xbmcHttp')
  end

  def method_missing(name, *args, &block)
    run name.to_s.classify, *args
  end
end