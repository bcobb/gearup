module Gearup
  class Logger

    attr_reader :basic_logger

    def initialize(file, level)
      @basic_logger = ::Logger.new(file)
      @basic_logger.level = level
    end

    %w(fatal error warn info debug).each do |logger_method|
      define_method(logger_method) do |message|
        @basic_logger.send(logger_method, preface(message))
      end
    end

    def method_missing(m, *args, &block)
      @basic_logger.send(m, *args, &block)
    end

    private

    def preface(message)
      "Gearup: #{message}"
    end

  end
end
