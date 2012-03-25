require 'ostruct'
require 'gearman'

module Gearup

  def self.run_from_file(file)
    lib = File.dirname(__FILE__)
    log = File.join(lib, '..', 'log', 'worker.log')
    logger = Logger.new(log)

    eval ::File.read(file), TOPLEVEL_BINDING, file

    ability = Example::Echo.new

    Gearman::Util.logger = logger
    options = { :network_timeout_sec => 2, :reconnect_sec => 4 }
    worker = Gearman::Worker.new('localhost:4730', options)
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

    worker.work
  end

end
