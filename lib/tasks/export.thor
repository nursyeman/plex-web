class Export < Thor
  PORT = 27386

  desc "static", "Export a static site"
  method_options %w[ --target -t ] => 'pkg/plex-web-static'
  def static
    load_dependencies

    with_rails_server do
      FileUtils.mkdir_p(options[:target])
      Dir.chdir(options[:target]) do
        save '/', 'index.html', true do |html|
          save_assets_in html, true do |asset|
            asset.gsub(%r{(url:\s*['"])/}) { $1 }
          end
        end

        data = save "/movies.json", nil, true
        movies = ActiveSupport::JSON.decode(data)

        movies.each do |movie|
          save((movie['fanarts'].values + movie['posters'].values).map { |art| art['url'] })
        end
      end
    end
  end

  no_tasks do
    def with_rails_server
      begin
        start_server

        if not wait_for_server
          abort "unable to start Rails server!"
        end

        yield
      ensure
        stop_server
      end
    end

    def start_server
      trap(:CHLD) {}
      @pid = fork
      if @pid.nil?
        $stdin.reopen("/dev/null")
        $stdout.reopen("/dev/null")
        $stderr.reopen("/dev/null")
        exec "bundle exec rails server -p #{PORT}"
      end
    end

    def wait_for_server
      10.times do
        %x{lsof -nP -i :#{PORT}}
        return true if listening?
        sleep 1
      end

      return false
    end

    def listening?
      %x{lsof -nP -i :#{PORT}}
      return $?.success?
    end

    def stop_server
      Process.kill :TERM, @pid if @pid
    end

    def save(url, file=nil, force=false, &callback)
      case url
      when Hash
        return url.map { |key, value| save key, value, force, &callback }
      when String
        return save(URI.parse(url), file, force, &callback)
      when Array
        return url.map { |u| save(u, nil, force, &callback) }
      end

      url = URI.join("http://localhost:#{PORT}", url)
      file ||= url.path[1..-1]

      if !force && File.exist?(file)
        # puts "*** skipping #{url}"
        return File.read(file)
      end

      puts "*** saving #{url} to #{File.expand_path(file)}"
      data = open(url.to_s).read
      data = yield data if block_given?
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') { |f| f << data}

      return data
    end

    def save_assets_in(page, force=false, &callback)
      doc = Nokogiri::HTML(page)
      %w[src href].each do |attr|
        doc.search("//*[@#{attr}]").each do |node|
          attribute = node.attributes[attr]
          url = attribute.value
          case url
          when %r{^/}
            save url, nil, force, &callback
            node.set_attribute attr, url[1..-1]
          when %r{^https?:}
            save url, nil, force, &callback
          else
            puts "*** skipping dubious asset #{url}"
          end
        end
      end

      return doc.to_s
    end

    def load_dependencies
      require 'fileutils'
      require 'open-uri'

      begin
        require File.expand_path('../../.bundle/environment', __FILE__)
      rescue LoadError
        require 'rubygems'
        require 'bundler'
        Bundler.setup
      end

      require 'nokogiri'
      require 'active_support/json'
    end
  end
end
