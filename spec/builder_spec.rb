require 'gearup'
require 'ostruct'

describe Gearup::Builder do

  module Test
    class WrapDataInBrackets

      def initialize(ability)
        @ability = ability
      end

      def call(env)
        env.data = "[#{env.data}]"

        @ability.call(env)
      end

    end

    class Logger

      def self.debug(message = nil)
        @messages ||= []

        if message
          @messages << message
        end

        @messages
      end

      def self.flush
        @messages = []
      end

    end

    class LogWorkerInputOutput

      def initialize(ability, logger)
        @ability = ability
        @logger = logger
      end

      def call(env)
        @logger.debug "Input: #{env.data}"

        result = @ability.call(env)

        @logger.debug "Output: #{result}"

        result
      end

    end

    class ParensAbility

      def call(env)
        "(#{env.data})"
      end

    end
  end

  let(:logger) { Test::Logger }
  let(:env) { OpenStruct.new(:data => 'data') }

  after { logger.flush }

  subject do
    Gearup::Builder.build do
      use Test::LogWorkerInputOutput, Test::Logger
      use Test::WrapDataInBrackets

      enable Test::ParensAbility.new
    end
  end

  it 'wraps data in brackets, then parenthesis' do
    subject.call(env).should == '([data])'
  end

  it 'logs input and output in its middleware' do
    subject.call(env)

    logger.debug.should == ['Input: data', 'Output: ([data])']
  end

end
