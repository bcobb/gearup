require 'ostruct'
require 'gearman'

require 'gearup/worker'

module Gearup

  class << self
    attr_reader :logger, :configuration
  end

  def self.run_from_file(file, configuration)
    @configuration = configuration # XXX: smelly
    start_logging

    eval ::File.read(file), TOPLEVEL_BINDING, file

    ability = Example::Echo.new

    worker.enable('example.echo') do |data, job|
      payload = OpenStruct.new(:data => data)

      ability.call(payload)
    end

    start_worker
  end

  def self.start_worker
    # XXX: option to run in foreground?
    daemonize
    remember_to_stop

    loop { worker.work }
  end

  def self.worker
    @worker ||= Gearup::Worker.new(configuration[:servers])
  end

  def self.servers
    configuration[:servers]
  end

  def self.configuration
    @configuration || {}
  end

  def self.start_logging
    @logger = Logger.new(configuration[:logfile])
    @logger.level = configuration[:loglevel]
    Gearman::Util.logger = @logger
  end

  def self.daemonize
    if RUBY_VERSION < "1.9"
      exit if fork
      ::Process.setsid
      exit if fork
      STDIN.reopen "/dev/null"
      STDOUT.reopen "/dev/null", "a"
      STDERR.reopen "/dev/null", "a"
    else
      ::Process.daemon
    end

    # XXX: configuration[:pid]
    pid_file = ::File.expand_path('gearup.pid')
    ::File.open(pid_file, 'w'){ |f| f.write("#{::Process.pid}") }

    logger.debug("Gearup: Wrote out #{pid_file}")

    at_exit { ::File.delete(pid_file) if ::File.exist?(pid_file) }
  end

  def self.remember_to_stop
    trap(:INT) do
      logger.debug "Gearup: Shutting down"

      worker.shutdown

      exit
    end
  end

  class CommandLineConfiguration

    def self.from(args)
      configuration = new(args)
      configuration.parse_options!
      configuration.options
    end

    def initialize(args)
      @args = args
      @options = { }
    end

    def parse_options!
      parser.parse!(@args)
    end

    def options
      {
        :logfile => ::File.expand_path('log/gearup.log'),
        :servers => ['localhost:4730'],
        :loglevel => Logger::INFO
      }.merge(@options)
    end

    private

    def parser
      OptionParser.new do |parser|
        parser.banner = "Usage: gearup [options] WORKER\n\n"

        parser.on('-s', '--server SERVERS', Array, 'Specify servers on which the worker will run.') do |servers|
          @options[:servers] = servers
        end

        parser.on('-v', '--verbose', 'Enable verbose (DEBUG-level) logging') do |verbose|
          @options[:verbose] = true
          @options[:loglevel] = Logger::DEBUG
        end

        parser.on('-l', '--logfile LOGFILE', "Specify Gearup's log location") do |logfile|
          file = File.expand_path(logfile)
          @options[:logfile] = file
        end

      end
    end

  end

end
