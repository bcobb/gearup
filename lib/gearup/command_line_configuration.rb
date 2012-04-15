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
        :logfile => STDOUT,
        :servers => ['localhost:4730'],
        :loglevel => ::Logger::INFO,
        :daemonize => false
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
          @options[:loglevel] = ::Logger::DEBUG
        end

        parser.on('-l', '--logfile LOGFILE', "Specify Gearup's log location") do |logfile|
          file = ::File.expand_path(logfile)
          @options[:logfile] = file
        end

        parser.on('-P', '--pid FILE', "Specify a file to store gearup's PID") do |pid|
          file = ::File.expand_path(pid)
          @options[:pid] = file
        end

        parser.on('-D', "Specify that the worker should be daemonized") do |daemonize|
          @options[:daemonize] = true
        end

      end
    end

  end
end
