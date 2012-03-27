require 'gearup'

describe Gearup::CommandLineConfiguration do

  def options_from(argv)
    Gearup::CommandLineConfiguration.from(argv)
  end

  describe '-s, --server' do

    it 'accepts one server' do
      options_from(%w(-s SERVER)).should include(:servers => ['SERVER'])
      options_from(%w(--server SERVER)).should include(:servers => ['SERVER'])
    end

    it 'accepts several servers' do
      options_from(%w(-s SERVER1,SERVER2)).should include(:servers => ['SERVER1', 'SERVER2'])
      options_from(%w(--server SERVER1,SERVER2)).should include(:servers => ['SERVER1', 'SERVER2'])
    end

    it 'defaults to localhost:4730' do
      options_from([]).should include(:servers => ['localhost:4730'])
    end

  end

  describe '-v, --verbose' do

    it 'toggles verbosity' do
      options_from(%w(-v)).should include(:verbose => true)
      options_from(%w(--verbose)).should include(:verbose => true)
    end

  end

  describe '-l, --logfile' do

    before { File.stub(:expand_path) }

    it 'specifies to where Gearup should log' do
      file = stub

      File.should_receive(:expand_path).with('log/loggy.log').twice { file }
      options_from(%w(-l log/loggy.log)).should include(:logfile => file)
      options_from(%w(--logfile log/loggy.log)).should include(:logfile => file)
    end

    it 'defaults to log/gearup.log' do
      file = stub

      File.should_receive(:expand_path).with('log/gearup.log') { file }
      options_from(%w()).should include(:logfile => file)
    end

  end

end
