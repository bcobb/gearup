require 'gearup'

describe Gearup::Worker do

  it 'uses abilities to do work' do
    ability, payload = stub, stub
    subject.enable ability

    ability.should_receive(:call).with(payload)

    subject.work(payload)
  end

end
