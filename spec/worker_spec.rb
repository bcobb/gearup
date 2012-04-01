require 'gearup'

describe Gearup::Worker do

  let(:gearman_worker) { stub(:after_ability => true, :add_ability => true) }

  before { Gearman::Worker.stub(:new).and_return(gearman_worker) }

  it 'delegates work to an internal gearman worker' do
    gearman_worker.should_receive(:work)

    subject.work
  end

  it 'enables abilities on the gearman worker' do
    ability = 'test'
    gearman_worker.should_receive(:add_ability).with(ability)

    subject.enable(ability)
    subject.should be_able_to_perform('test')
  end

  it 'can disable abilities on the gearman worker' do
    ability = 'test'

    gearman_worker.should_receive(:remove_ability).with(ability)
    subject.enable(ability)
    subject.disable(ability)

    subject.should_not be_able_to_perform(ability)
  end

  it 'disables all abilities and the worker on shutdown' do
    subject.should_receive(:disable).with('test')
    gearman_worker.should_receive(:worker_enabled=).with(false)

    subject.enable('test')
    subject.shutdown
  end

end
