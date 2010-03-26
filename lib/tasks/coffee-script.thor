require 'fileutils'

module Helpers
  def capture(*cmd)
    Command.capture(*cmd)
  end

  def system_or_die(*cmd)
    Command.system_or_raise(*cmd)
  rescue => e
    $stdout.puts e
    exit(1)
  end
end

class CoffeeScript < Thor
  namespace :coffee

  include Helpers

  desc 'install', 'Install CoffeeScript using Homebrew'
  method_options %w( force -f ) => false

  def install
    Brew.assert_installed

    if installed?
      if options[:force]
        system_or_die "brew rm coffee-script"
      else
        puts "NOTE: CoffeeScript #{version} is already installed, use --force to reinstall it"
        exit(0)
      end
    end

    node.install unless node.installed?
    system_or_die "brew install coffee-script"
  end

  no_tasks do
    def installed?(version_to_check=nil)
      if version_to_check
        version == version_to_check
      else
        version != nil
      end
    end

    def version
      Version.from capture(%w[coffee -v]).chomp
    rescue Command::Error
      nil
    end

    def node
      @node ||= Node.new
    end
  end
end

class Node < Thor
  DEFAULT_VERSION = '0.1.33'.freeze

  include Helpers

  desc 'install', 'Install node.js'
  method_options %w( version -v ) => DEFAULT_VERSION
  method_options %w( force -f ) => false

  def install
    Brew.assert_installed

    if installed?
      if version != target_version
        puts "NOTE: node.js #{version} is already installed, you may need to `brew rm node` first"
      elsif not options[:force]
        puts "node.js #{version} is already installed, use --force to reinstall it"
        exit(0)
      end
    end

    with_scratch_directory do
      system_or_die "curl http://nodejs.org/dist/node-v#{target_version}.tar.gz | tar xz --strip-components 1"
      system_or_die "./configure --prefix=#{Brew.prefix}/Cellar/node/#{target_version}"

      # this is really, really, stupid, but node doesn't seem to build properly without sudo,
      # and even then it seem sketchy. but this seems to work. no idea why. suggestions welcome
      system_or_die "sudo make || make || sudo make"

      system_or_die "sudo chown -R #{ENV['USER']}:staff ."
      system_or_die "make install"
      system_or_die "brew link node"
    end
  end

  no_tasks do
    def installed?(version_to_check=nil)
      if version_to_check
        version == version_to_check
      else
        version != nil
      end
    end

    def version
      Version.from capture(%w[node -v]).chomp
    rescue Command::Error
      nil
    end

    def target_version
      Version.from options[:version] || DEFAULT_VERSION
    end

    def with_scratch_directory(&block)
      work_directory = File.expand_path("../../../tmp/scratch/#{self.class}/#{object_id}", __FILE__)
      FileUtils.mkdir_p(work_directory)
      Dir.chdir(work_directory, &block)
      FileUtils.rm_rf(work_directory)
    end
  end
end

module Brew
  extend self

  def prefix
    Command.capture(%w[brew --prefix]).chomp
  rescue Command::Error
    nil
  end

  def installed?
    prefix != nil
  end

  def assert_installed
    abort "homebrew is not installed\ninstall from http://github.com/mxcl/homebrew" unless installed?
  end
end

class Command
  attr_accessor :command, :stdout, :stderr, :process

  class Error < RuntimeError
    def initialize(command)
      error = "command failed"
      error << " ($?=#{command.process.exitstatus})" if command.process
      error << ": #{command.command_string}"
      error << "\n\nOUTPUT:\n\n#{command.stdout}" if command.stdout && !command.stdout.empty?

      super error
    end
  end

  def initialize(*command)
    @command = command.flatten
    yield self if block_given?
  end

  def run
    self.stdout  = %x{#{command_string} 2>&1}
    self.process = $?
  end

  def command_string
    command.join(' ')
  end

  def system_or_raise
    puts "+ #{command_string}"
    system(*command)
    self.process = $?
    return self if $?.success?

    raise Command::Error, self
  end

  def run_or_raise
    run
    return self if process.success?

    raise Command::Error, self
  end

  def capture
    run_or_raise.stdout
  end

  def self.capture(*cmd)
    new(*cmd).capture
  end

  def self.system_or_raise(*cmd)
    new(*cmd).system_or_raise
  end
end

class Version
  attr_reader :parts

  def initialize(version_string)
    @parts = version_string.split('.').map {|s| s.to_i}
  end

  def <=>(other)
    parts <=> other.parts
  end

  def to_s
    parts.join('.')
  end

  def ==(other)
    other.is_a?(self.class) && parts == other.parts
  end

  def self.from(version)
    return version if version.is_a?(Version)
    Version.new(version[/\b(\d(?:\.\d+)+)\b/, 1])
  end
end