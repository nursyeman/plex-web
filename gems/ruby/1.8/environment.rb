# DO NOT MODIFY THIS FILE
module Bundler
 file = File.expand_path(__FILE__)
 dir = File.dirname(file)

  ENV["GEM_HOME"] = dir
  ENV["GEM_PATH"] = dir

  # handle 1.9 where system gems are always on the load path
  if defined?(::Gem)
    $LOAD_PATH.reject! do |p|
      p != File.dirname(__FILE__) &&
        Gem.path.any? { |gp| p.include?(gp) }
    end
  end

  ENV["PATH"]     = "#{dir}/../../../bin:#{ENV["PATH"]}"
  ENV["RUBYOPT"]  = "-r#{file} #{ENV["RUBYOPT"]}"

  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/nokogiri-1.4.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/nokogiri-1.4.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/nokogiri-1.4.1/ext")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/activesupport-2.3.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/activesupport-2.3.5/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/actionmailer-2.3.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/actionmailer-2.3.5/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.0.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.0.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/actionpack-2.3.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/actionpack-2.3.5/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/mime-types-1.16/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/mime-types-1.16/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rest-client-1.2.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rest-client-1.2.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rspec-1.3.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rspec-1.3.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rspec-rails-1.3.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rspec-rails-1.3.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/haml-2.2.17/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/haml-2.2.17/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sqlite3-ruby-1.2.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sqlite3-ruby-1.2.5/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sqlite3-ruby-1.2.5/ext")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/authlogic-2.1.3/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/authlogic-2.1.3/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rake-0.8.7/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rake-0.8.7/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/activerecord-2.3.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/activerecord-2.3.5/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/compass-0.8.17/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/compass-0.8.17/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/activeresource-2.3.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/activeresource-2.3.5/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rails-2.3.5/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rails-2.3.5/lib")

  @gemfile = "#{dir}/../../../Gemfile"

  require "rubygems" unless respond_to?(:gem) # 1.9 already has RubyGems loaded

  @bundled_specs = {}
  @bundled_specs["nokogiri"] = eval(File.read("#{dir}/specifications/nokogiri-1.4.1.gemspec"))
  @bundled_specs["nokogiri"].loaded_from = "#{dir}/specifications/nokogiri-1.4.1.gemspec"
  @bundled_specs["activesupport"] = eval(File.read("#{dir}/specifications/activesupport-2.3.5.gemspec"))
  @bundled_specs["activesupport"].loaded_from = "#{dir}/specifications/activesupport-2.3.5.gemspec"
  @bundled_specs["actionmailer"] = eval(File.read("#{dir}/specifications/actionmailer-2.3.5.gemspec"))
  @bundled_specs["actionmailer"].loaded_from = "#{dir}/specifications/actionmailer-2.3.5.gemspec"
  @bundled_specs["rack"] = eval(File.read("#{dir}/specifications/rack-1.0.1.gemspec"))
  @bundled_specs["rack"].loaded_from = "#{dir}/specifications/rack-1.0.1.gemspec"
  @bundled_specs["actionpack"] = eval(File.read("#{dir}/specifications/actionpack-2.3.5.gemspec"))
  @bundled_specs["actionpack"].loaded_from = "#{dir}/specifications/actionpack-2.3.5.gemspec"
  @bundled_specs["mime-types"] = eval(File.read("#{dir}/specifications/mime-types-1.16.gemspec"))
  @bundled_specs["mime-types"].loaded_from = "#{dir}/specifications/mime-types-1.16.gemspec"
  @bundled_specs["rest-client"] = eval(File.read("#{dir}/specifications/rest-client-1.2.0.gemspec"))
  @bundled_specs["rest-client"].loaded_from = "#{dir}/specifications/rest-client-1.2.0.gemspec"
  @bundled_specs["rspec"] = eval(File.read("#{dir}/specifications/rspec-1.3.0.gemspec"))
  @bundled_specs["rspec"].loaded_from = "#{dir}/specifications/rspec-1.3.0.gemspec"
  @bundled_specs["rspec-rails"] = eval(File.read("#{dir}/specifications/rspec-rails-1.3.2.gemspec"))
  @bundled_specs["rspec-rails"].loaded_from = "#{dir}/specifications/rspec-rails-1.3.2.gemspec"
  @bundled_specs["haml"] = eval(File.read("#{dir}/specifications/haml-2.2.17.gemspec"))
  @bundled_specs["haml"].loaded_from = "#{dir}/specifications/haml-2.2.17.gemspec"
  @bundled_specs["sqlite3-ruby"] = eval(File.read("#{dir}/specifications/sqlite3-ruby-1.2.5.gemspec"))
  @bundled_specs["sqlite3-ruby"].loaded_from = "#{dir}/specifications/sqlite3-ruby-1.2.5.gemspec"
  @bundled_specs["authlogic"] = eval(File.read("#{dir}/specifications/authlogic-2.1.3.gemspec"))
  @bundled_specs["authlogic"].loaded_from = "#{dir}/specifications/authlogic-2.1.3.gemspec"
  @bundled_specs["rake"] = eval(File.read("#{dir}/specifications/rake-0.8.7.gemspec"))
  @bundled_specs["rake"].loaded_from = "#{dir}/specifications/rake-0.8.7.gemspec"
  @bundled_specs["activerecord"] = eval(File.read("#{dir}/specifications/activerecord-2.3.5.gemspec"))
  @bundled_specs["activerecord"].loaded_from = "#{dir}/specifications/activerecord-2.3.5.gemspec"
  @bundled_specs["compass"] = eval(File.read("#{dir}/specifications/compass-0.8.17.gemspec"))
  @bundled_specs["compass"].loaded_from = "#{dir}/specifications/compass-0.8.17.gemspec"
  @bundled_specs["activeresource"] = eval(File.read("#{dir}/specifications/activeresource-2.3.5.gemspec"))
  @bundled_specs["activeresource"].loaded_from = "#{dir}/specifications/activeresource-2.3.5.gemspec"
  @bundled_specs["rails"] = eval(File.read("#{dir}/specifications/rails-2.3.5.gemspec"))
  @bundled_specs["rails"].loaded_from = "#{dir}/specifications/rails-2.3.5.gemspec"

  def self.add_specs_to_loaded_specs
    Gem.loaded_specs.merge! @bundled_specs
  end

  def self.add_specs_to_index
    @bundled_specs.each do |name, spec|
      Gem.source_index.add_spec spec
    end
  end

  add_specs_to_loaded_specs
  add_specs_to_index

  def self.require_env(env = nil)
    context = Class.new do
      def initialize(env) @env = env && env.to_s ; end
      def method_missing(*) ; yield if block_given? ; end
      def only(*env)
        old, @only = @only, _combine_only(env.flatten)
        yield
        @only = old
      end
      def except(*env)
        old, @except = @except, _combine_except(env.flatten)
        yield
        @except = old
      end
      def gem(name, *args)
        opt = args.last.is_a?(Hash) ? args.pop : {}
        only = _combine_only(opt[:only] || opt["only"])
        except = _combine_except(opt[:except] || opt["except"])
        files = opt[:require_as] || opt["require_as"] || name
        files = [files] unless files.respond_to?(:each)

        return unless !only || only.any? {|e| e == @env }
        return if except && except.any? {|e| e == @env }

        if files = opt[:require_as] || opt["require_as"]
          files = Array(files)
          files.each { |f| require f }
        else
          begin
            require name
          rescue LoadError
            # Do nothing
          end
        end
        yield if block_given?
        true
      end
      private
      def _combine_only(only)
        return @only unless only
        only = [only].flatten.compact.uniq.map { |o| o.to_s }
        only &= @only if @only
        only
      end
      def _combine_except(except)
        return @except unless except
        except = [except].flatten.compact.uniq.map { |o| o.to_s }
        except |= @except if @except
        except
      end
    end
    context.new(env && env.to_s).instance_eval(File.read(@gemfile), @gemfile, 1)
  end
end

module Gem
  @loaded_stacks = Hash.new { |h,k| h[k] = [] }

  def source_index.refresh!
    super
    Bundler.add_specs_to_index
  end
end
