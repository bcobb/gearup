module Gearup

  autoload :BuildsWorkers, 'gearup/builds_workers'
  autoload :Worker, 'gearup/worker'
  autoload :Middleware, 'gearup/middleware'
  autoload :GearmanRunner, 'gearup/gearman_runner'

  def self.run_from_file(file)
    worker = Gearup::BuildsWorkers.build_from_file(file)

    Gearup::GearmanRunner.run worker
  end

end
