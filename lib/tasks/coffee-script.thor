require 'fileutils'

class CoffeeScript < Thor
  namespace :coffee

  desc 'install', 'Install CoffeeScript using Homebrew'
  method_options %w( force -f ) => false

  def install
    Brew.assert_installed

    if installed? && !options[:force]
      puts "NOTE: CoffeeScript #{version} is already installed"
      exit(0)
    end

    node.install unless node.installed?
    Command.system_or_die "brew install coffee-script"
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
      Version.from Command.capture(%w[coffee -v]).chomp
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
      Command.system_or_die "curl http://nodejs.org/dist/node-v#{target_version}.tar.gz | tar xz --strip-components 1"
      Command.system_or_die "./configure --prefix=#{Brew.prefix}/Cellar/node/#{target_version}"
      Command.system_or_die "sudo make"
      Command.system_or_die "chmod -R '#{ENV['USER']}':staff ."
      Command.system_or_die "make install"
      Command.system_or_die "brew link node"
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
      Version.from Command.capture(%w[node -v]).chomp
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
    Command.new(%w[brew --prefix]).capture.chomp
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

  def system_or_die
    puts "+ #{command_string}"
    system(*command)
    self.process = $?
    return self if $?.success?

    raise Command::Error, self
  end

  def run_or_die
    run
    return self if process.success?

    raise Command::Error, self
  end

  def capture
    run_or_die.stdout
  end

  def self.capture(*cmd)
    new(*cmd).capture
  rescue => e
    $stdout.puts e
    exit(1)
  end

  def self.system_or_die(*cmd)
    new(*cmd).system_or_die
  rescue => e
    $stdout.puts e
    exit(1)
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
    Version.new(version)
  end
end