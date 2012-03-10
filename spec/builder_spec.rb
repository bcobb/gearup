require 'gearup'

describe Gearup::Builder do

  it 'can build workers from files' do
    payload = stub(:data => 'reverse')
    worker = Gearup::Builder.build_from_file('example/reverse.rb')

    worker.work(payload).should == 'esrever'
  end

  it 'can build workers' do
    payload = stub(:data => 'echo me!')

    worker = Gearup::Builder.build do
      enable lambda { |payload| payload.data }
    end

    worker.work(payload).should == 'echo me!'
  end

end
