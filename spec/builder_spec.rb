require 'gearup'

describe Gearup::Builder do

  it 'can build workers from files' do
    worker = Gearup::Builder.build_from_file('example/reverse.rb')

    worker.work(stub(:data => 'reverse')).should == 'esrever'
  end

end
