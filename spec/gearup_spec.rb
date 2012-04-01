require 'gearup'

describe Gearup do

  it 'knows how to enable abilities on workers' do
    Gearup.worker.should_receive(:enable).with('test')

    Gearup.enable('test', stub)
  end

end
