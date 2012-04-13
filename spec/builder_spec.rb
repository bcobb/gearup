require 'gearup'

describe Gearup::Builder do

  let(:worker) { stub }
  subject { Gearup::Builder.new(worker) }

  it 'knows how to enable abilities on workers' do
    ability, gearup_ability = stub, stub

    subject.stub(:gearup_ability_for).with(ability).and_return(gearup_ability)
    subject.worker.should_receive(:enable).with('test', gearup_ability)

    subject.enable('test', ability)
  end

  it 'can add middleware to the stack' do
    middleware = stub

    subject.use(middleware)
    subject.should be_using_middleware(middleware)
  end

  it 'can add middleware to the stack, along with dependencies' do
    middleware, dependency = stub, stub

    subject.use(middleware, dependency)
  end

end
