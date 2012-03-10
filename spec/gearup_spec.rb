require 'gearup'

describe Gearup do

  it 'can run workers by reading files' do
    file, worker = stub, stub

    Gearup::Builder.should_receive(:build_from_file).with(file) { worker }

    Gearup::GearmanRunner.should_receive(:run).with(worker)

    Gearup.run_from_file(file)
  end

end
