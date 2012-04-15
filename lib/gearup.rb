require 'ostruct'
require 'logger'
require 'gearman'

require 'gearup/command_line_configuration'
require 'gearup/builder'
require 'gearup/worker'
require 'gearup/logger'

module Gearup

  class << self
    attr_reader :logger, :configuration
  end

  def self.run_from_file(file, configuration)
    @configuration = configuration # XXX: smelly
    start_logging

    worker = Builder.build_from_file(file)

    start(worker)
  end

  def self.start(worker)
    # XXX: option to run in foreground?
    daemonize
    write_pid(configuration[:pid]) if configuration[:pid]
    remember_to_stop(worker)

    loop { worker.work }
  end

  def self.servers
    configuration[:servers]
  end

  def self.configuration
    @configuration || {}
  end

  def self.start_logging
    @logger = begin
      Logger.new(configuration[:logfile], configuration[:loglevel])
    rescue => e
      if configuration[:verbose]
        warn "Couldn't open file #{configuration[:logfile]}. Logging to STDOUT."
      end

      Logger.new(STDOUT, configuration[:loglevel])
    end

    Gearman::Util.logger = @logger.basic_logger
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
  end

  def self.write_pid(pid_file)
    ::File.open(pid_file, 'w'){ |f| f.write("#{::Process.pid}") }

    logger.debug("Wrote out #{pid_file}")

    at_exit { ::File.delete(pid_file) if ::File.exist?(pid_file) }
  end

  def self.remember_to_stop(worker)
    trap(:INT) do
      logger.debug "Shutting down"

      worker.shutdown

      exit
    end
  end

end
