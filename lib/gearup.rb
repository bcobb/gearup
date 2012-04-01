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
    @logger = Gearup::Logger.new
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

    # XXX: configuration[:pid]
    pid_file = ::File.expand_path('gearup.pid')
    ::File.open(pid_file, 'w'){ |f| f.write("#{::Process.pid}") }

    logger.debug("Gearup: Wrote out #{pid_file}")

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
