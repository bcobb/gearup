module Gearup

  autoload :Builder, 'gearup/builder'
  autoload :Worker, 'gearup/worker'
  autoload :Middleware, 'gearup/middleware'
  autoload :GearmanRunner, 'gearup/gearman_runner'

  def self.run_from_file(file)
    worker = Gearup::Builder.build_from_file(file)

    Gearup::GearmanRunner.run worker
  end

end
