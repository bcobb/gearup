require 'ostruct'
require 'gearman'

module Gearup

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
        :servers => ['localhost:4730']
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
        end

        parser.on('-l', '--logfile LOGFILE', "Specify Gearup's log location") do |logfile|
          file = File.expand_path(logfile)
          @options[:logfile] = file
        end

      end
    end

  end

  def self.run_from_file(file, configuration)
    logger = Logger.new(configuration[:logfile])
    if configuration[:verbose]
      logger.level = Logger::DEBUG
    else
      logger.level = Logger::INFO
    end

    eval ::File.read(file), TOPLEVEL_BINDING, file

    ability = Example::Echo.new

    Gearman::Util.logger = logger
    options = { :network_timeout_sec => 2, :reconnect_sec => 4 }
    worker = Gearman::Worker.new(configuration[:servers], options)
    worker.add_ability('example.echo') do |data, job|
      payload = OpenStruct.new(:data => data)

      ability.call(payload)
    end

    worker.after_ability('example.echo') do |result, data|
      payload = OpenStruct.new(:data => data)

      logger.debug("Got #{result.inspect} from #{payload.inspect}")
    end

    logger.debug "Daemonizing"

    if RUBY_VERSION < "1.9"
      exit if fork
      Process.setsid
      exit if fork
      STDIN.reopen "/dev/null"
      STDOUT.reopen "/dev/null", "a"
      STDERR.reopen "/dev/null", "a"
    else
      Process.daemon
    end

    pid_file = File.expand_path('gearup.pid')
    logger.debug("Writing out #{pid_file}")
    ::File.open(pid_file, 'w'){ |f| f.write("#{Process.pid}") }
    at_exit { ::File.delete(pid_file) if ::File.exist?(pid_file) }

    trap(:INT) do
      logger.debug "Gearup: Shutting down"
      worker.remove_ability('example.echo')

      worker.worker_enabled = false

      exit
    end

    logger.debug "Daemonized"

    loop { worker.work }
  end

end
