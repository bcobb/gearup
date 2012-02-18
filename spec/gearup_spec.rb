require 'gearup'
require 'ostruct'

module Test
  class WrapDataInBrackets

    def initialize(worker)
      @worker = worker
    end

    def call(env)
      env.data = "[#{env.data}]"

      @worker.call(env)
    end

  end

  class LogWorkerInputOutput

    def initialize(worker, logger)
      @worker = worker
      @logger = logger
    end

    def call(env)
      @logger.debug "Input: #{env.data}"

      result = @worker.call(env)

      @logger.debug "Output: #{result}"
    end

  end

  class ParensWorker

    def initialize(worker)
      @worker = worker
    end

    def call(env)
      "(#{env.data})"
    end

  end
end

describe "A geared-up worker" do

  let(:logger) { stub(:logger, :debug => true) }
  let(:data) { OpenStruct.new(:data => 'data') }

  subject do
    Gearup::Builder.build do
      use WrapDataInBrackets
      use LogWorkerInputOutput, logger

      run ParensWorker
    end
  end

  it 'wraps data in brackets, then parenthesis' do
    subject.call(data).should == '([data])'
  end

  it 'logs input and output in its middleware' do
    logger.should_receive(:debug).with('Input: [data]')
    logger.should_receive(:debug).with('Output: ([data])')

    subject.call(data)
  end

end
