require 'gearup'

describe Gearup::CommandLineConfiguration do

  def options_from(argv)
    Gearup::CommandLineConfiguration.from(argv)
  end

  def default_options
    options_from([])
  end

  def file(file_name)
    ::File.expand_path(file_name)
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
      default_options.should include(:servers => ['localhost:4730'])
    end

  end

  describe '-v, --verbose' do

    it 'toggles verbosity' do
      options_from(%w(-v)).should include(:verbose => true)
      options_from(%w(--verbose)).should include(:verbose => true)
    end

  end

  describe '-l, --logfile' do

    it 'specifies to where Gearup should log' do
      log = file('log/loggy.log')

      options_from(%w(-l log/loggy.log)).should include(:logfile => log)
      options_from(%w(--logfile log/loggy.log)).should include(:logfile => log)
    end

    it 'defaults to log/gearup.log' do
      logfile = file('log/gearup.log')

      default_options.should include(:logfile => logfile)
    end

  end

  describe '-P, --pid' do

    it 'specifies the name of the PID file gearup writes to' do
      pid = file('process.pid')

      options_from(%w(-P process.pid)).should include(:pid => pid)
      options_from(%w(--pid process.pid)).should include(:pid => pid)
    end

    it 'does not have a default' do
      default_options.should_not include :pid
    end

  end

end
