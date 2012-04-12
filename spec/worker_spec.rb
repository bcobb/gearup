require 'gearup'

describe Gearup::Worker do

  let(:gearman_worker) { stub(:after_ability => true, :add_ability => true) }

  before { Gearman::Worker.stub(:new).and_return(gearman_worker) }

  it 'delegates work to an internal gearman worker' do
    gearman_worker.should_receive(:work)

    subject.work
  end

  it 'enables abilities on the gearman worker' do
    ability_name = 'test'
    gearman_worker.should_receive(:add_ability).with(ability_name)

    subject.enable(ability_name, stub)
    subject.should be_able_to_perform('test')
  end

  it 'can disable abilities on the gearman worker' do
    ability_name = 'test'

    gearman_worker.should_receive(:remove_ability).with(ability_name)
    subject.enable(ability_name, stub)
    subject.disable(ability_name)

    subject.should_not be_able_to_perform(ability_name)
  end

  it 'disables all abilities and the worker on shutdown' do
    subject.should_receive(:disable).with('test')
    gearman_worker.should_receive(:worker_enabled=).with(false)

    subject.enable('test', stub)
    subject.shutdown
  end

end
