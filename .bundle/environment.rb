# DO NOT MODIFY THIS FILE

require 'digest/sha1'
require 'rubygems'

module Gem
  class Dependency
    if !instance_methods.map { |m| m.to_s }.include?("requirement")
      def requirement
        version_requirements
      end
    end
  end
end

module Bundler
  module SharedHelpers

    def default_gemfile
      gemfile = find_gemfile
      gemfile or raise GemfileNotFound, "The default Gemfile was not found"
      Pathname.new(gemfile)
    end

    def in_bundle?
      find_gemfile
    end

  private

    def find_gemfile
      return ENV['BUNDLE_GEMFILE'] if ENV['BUNDLE_GEMFILE']

      previous = nil
      current  = File.expand_path(Dir.pwd)

      until !File.directory?(current) || current == previous
        filename = File.join(current, 'Gemfile')
        return filename if File.file?(filename)
        current, previous = File.expand_path("..", current), current
      end
    end

    def clean_load_path
      # handle 1.9 where system gems are always on the load path
      if defined?(::Gem)
        me = File.expand_path("../../", __FILE__)
        $LOAD_PATH.reject! do |p|
          next if File.expand_path(p).include?(me)
          p != File.dirname(__FILE__) &&
            Gem.path.any? { |gp| p.include?(gp) }
        end
        $LOAD_PATH.uniq!
      end
    end

    def reverse_rubygems_kernel_mixin
      # Disable rubygems' gem activation system
      ::Kernel.class_eval do
        if private_method_defined?(:gem_original_require)
          alias rubygems_require require
          alias require gem_original_require
        end

        undef gem
      end
    end

    def cripple_rubygems(specs)
      reverse_rubygems_kernel_mixin

      executables = specs.map { |s| s.executables }.flatten

     :: Kernel.class_eval do
        private
        def gem(*) ; end
      end
      Gem.source_index # ensure RubyGems is fully loaded

      ::Kernel.send(:define_method, :gem) do |dep, *reqs|
        if executables.include? File.basename(caller.first.split(':').first)
          return
        end
        opts = reqs.last.is_a?(Hash) ? reqs.pop : {}

        unless dep.respond_to?(:name) && dep.respond_to?(:requirement)
          dep = Gem::Dependency.new(dep, reqs)
        end

        spec = specs.find  { |s| s.name == dep.name }

        if spec.nil?
          e = Gem::LoadError.new "#{dep.name} is not part of the bundle. Add it to Gemfile."
          e.name = dep.name
          e.version_requirement = dep.requirement
          raise e
        elsif dep !~ spec
          e = Gem::LoadError.new "can't activate #{dep}, already activated #{spec.full_name}. " \
                                 "Make sure all dependencies are added to Gemfile."
          e.name = dep.name
          e.version_requirement = dep.requirement
          raise e
        end

        true
      end

      # === Following hacks are to improve on the generated bin wrappers ===

      # Yeah, talk about a hack
      source_index_class = (class << Gem::SourceIndex ; self ; end)
      source_index_class.send(:define_method, :from_gems_in) do |*args|
        source_index = Gem::SourceIndex.new
        source_index.spec_dirs = *args
        source_index.add_specs(*specs)
        source_index
      end

      # OMG more hacks
      gem_class = (class << Gem ; self ; end)
      gem_class.send(:define_method, :bin_path) do |name, *args|
        exec_name, *reqs = args

        spec = nil

        if exec_name
          spec = specs.find { |s| s.executables.include?(exec_name) }
          spec or raise Gem::Exception, "can't find executable #{exec_name}"
        else
          spec = specs.find  { |s| s.name == name }
          exec_name = spec.default_executable or raise Gem::Exception, "no default executable for #{spec.full_name}"
        end

        gem_bin = File.join(spec.full_gem_path, spec.bindir, exec_name)
        gem_from_path_bin = File.join(File.dirname(spec.loaded_from), spec.bindir, exec_name)
        File.exist?(gem_bin) ? gem_bin : gem_from_path_bin
      end
    end

    extend self
  end
end

module Bundler
  LOCKED_BY    = '0.9.13'
  FINGERPRINT  = "7ca7833062e0dc94355ad684f1173f83a752e7aa"
  AUTOREQUIRES = {:default=>[["haml", false], ["nokogiri", false], ["rack-coffee", false], ["rails", false], ["rest-client", false], ["sqlite3", false]], :test=>[["rspec-rails", false]]}
  SPECS        = [
        {:name=>"rake", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378%global/gems/rake-0.8.7/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378%global/specifications/rake-0.8.7.gemspec"},
        {:name=>"abstract", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/abstract-1.0.0/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/abstract-1.0.0.gemspec"},
        {:name=>"builder", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/builder-2.1.2/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/builder-2.1.2.gemspec"},
        {:name=>"i18n", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/i18n-0.3.6/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/i18n-0.3.6.gemspec"},
        {:name=>"memcache-client", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/memcache-client-1.7.8/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/memcache-client-1.7.8.gemspec"},
        {:name=>"tzinfo", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/tzinfo-0.3.17/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/tzinfo-0.3.17.gemspec"},
        {:name=>"activesupport", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/activesupport-3.0.0.beta/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/activesupport-3.0.0.beta.gemspec"},
        {:name=>"activemodel", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/activemodel-3.0.0.beta/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/activemodel-3.0.0.beta.gemspec"},
        {:name=>"erubis", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/erubis-2.6.5/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/erubis-2.6.5.gemspec"},
        {:name=>"rack", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rack-1.1.0/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rack-1.1.0.gemspec"},
        {:name=>"rack-mount", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rack-mount-0.4.7/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rack-mount-0.4.7.gemspec"},
        {:name=>"rack-test", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rack-test-0.5.3/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rack-test-0.5.3.gemspec"},
        {:name=>"actionpack", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/actionpack-3.0.0.beta/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/actionpack-3.0.0.beta.gemspec"},
        {:name=>"mime-types", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/mime-types-1.16/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/mime-types-1.16.gemspec"},
        {:name=>"mail", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/mail-2.1.3/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/mail-2.1.3.gemspec"},
        {:name=>"text-hyphen", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/text-hyphen-1.0.0/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/text-hyphen-1.0.0.gemspec"},
        {:name=>"text-format", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/text-format-1.0.0/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/text-format-1.0.0.gemspec"},
        {:name=>"actionmailer", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/actionmailer-3.0.0.beta/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/actionmailer-3.0.0.beta.gemspec"},
        {:name=>"arel", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/arel-0.2.1/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/arel-0.2.1.gemspec"},
        {:name=>"activerecord", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/activerecord-3.0.0.beta/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/activerecord-3.0.0.beta.gemspec"},
        {:name=>"activeresource", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/activeresource-3.0.0.beta/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/activeresource-3.0.0.beta.gemspec"},
        {:name=>"bundler", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/bundler-0.9.13/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/bundler-0.9.13.gemspec"},
        {:name=>"ffi", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/ffi-0.6.3/lib", "/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/ffi-0.6.3/ext"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/ffi-0.6.3.gemspec"},
        {:name=>"haml", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/haml-2.2.22/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/haml-2.2.22.gemspec"},
        {:name=>"nokogiri", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/nokogiri-1.4.1/lib", "/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/nokogiri-1.4.1/ext"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/nokogiri-1.4.1.gemspec"},
        {:name=>"rack-coffee", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rack-coffee-0.3.2/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rack-coffee-0.3.2.gemspec"},
        {:name=>"thor", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/thor-0.13.4/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/thor-0.13.4.gemspec"},
        {:name=>"railties", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/railties-3.0.0.beta/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/railties-3.0.0.beta.gemspec"},
        {:name=>"rails", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rails-3.0.0.beta/"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rails-3.0.0.beta.gemspec"},
        {:name=>"rest-client", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rest-client-1.4.2/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rest-client-1.4.2.gemspec"},
        {:name=>"rspec-core", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rspec-core-2.0.0.beta.4/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rspec-core-2.0.0.beta.4.gemspec"},
        {:name=>"rspec-expectations", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rspec-expectations-2.0.0.beta.4/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rspec-expectations-2.0.0.beta.4.gemspec"},
        {:name=>"rspec-mocks", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rspec-mocks-2.0.0.beta.4/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rspec-mocks-2.0.0.beta.4.gemspec"},
        {:name=>"rspec", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rspec-2.0.0.beta.4/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rspec-2.0.0.beta.4.gemspec"},
        {:name=>"webrat", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/webrat-0.7.0/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/webrat-0.7.0.gemspec"},
        {:name=>"rspec-rails", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/rspec-rails-2.0.0.beta.4/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/rspec-rails-2.0.0.beta.4.gemspec"},
        {:name=>"sqlite3", :load_paths=>["/Users/donovan/.rvm/gems/ruby-1.9.1-p378/gems/sqlite3-0.0.8/lib"], :loaded_from=>"/Users/donovan/.rvm/gems/ruby-1.9.1-p378/specifications/sqlite3-0.0.8.gemspec"},
      ].map do |hash|
    if hash[:virtual_spec]
      spec = eval(hash[:virtual_spec], binding, "<virtual spec for '#{hash[:name]}'>")
    else
      dir = File.dirname(hash[:loaded_from])
      spec = Dir.chdir(dir){ eval(File.read(hash[:loaded_from]), binding, hash[:loaded_from]) }
    end
    spec.loaded_from = hash[:loaded_from]
    spec.require_paths = hash[:load_paths]
    spec
  end

  extend SharedHelpers

  def self.configure_gem_path_and_home(specs)
    # Fix paths, so that Gem.source_index and such will work
    paths = specs.map{|s| s.installation_path }
    paths.flatten!; paths.compact!; paths.uniq!; paths.reject!{|p| p.empty? }
    ENV['GEM_PATH'] = paths.join(File::PATH_SEPARATOR)
    ENV['GEM_HOME'] = paths.first
    Gem.clear_paths
  end

  def self.match_fingerprint
    print = Digest::SHA1.hexdigest(File.read(File.expand_path('../../Gemfile', __FILE__)))
    unless print == FINGERPRINT
      abort 'Gemfile changed since you last locked. Please `bundle lock` to relock.'
    end
  end

  def self.setup(*groups)
    match_fingerprint
    clean_load_path
    cripple_rubygems(SPECS)
    configure_gem_path_and_home(SPECS)
    SPECS.each do |spec|
      Gem.loaded_specs[spec.name] = spec
      $LOAD_PATH.unshift(*spec.require_paths)
    end
  end

  def self.require(*groups)
    groups = [:default] if groups.empty?
    groups.each do |group|
      (AUTOREQUIRES[group.to_sym] || []).each do |file, explicit|
        if explicit
          Kernel.require file
        else
          begin
            Kernel.require file
          rescue LoadError
          end
        end
      end
    end
  end

  # Setup bundle when it's required.
  setup
end
