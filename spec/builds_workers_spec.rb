require 'gearup'

describe Gearup::BuildsWorkers do

  it 'can build workers from files' do
    payload = stub(:data => 'reverse')
    worker = Gearup::BuildsWorkers.build_from_file('example/reverse.rb')

    worker.call(payload).should == 'esrever'
  end

  it 'can build workers' do
    payload = stub(:data => 'echo me!')

    worker = Gearup::BuildsWorkers.build do
      enable lambda { |payload| payload.data }
    end

    worker.call(payload).should == 'echo me!'
  end

end
