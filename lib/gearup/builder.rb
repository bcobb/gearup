module Gearup
  class Builder

    def self.build_from_file(file)
      worker = Worker.new(Gearup.configuration[:servers])
      builder = new(worker)

      builder.instance_eval(::File.read(file))
      builder.worker
    end

    attr_reader :worker

    def initialize(worker_to_be_built)
      @worker = worker_to_be_built
      @middleware = []
      @dependencies = []
    end

    def enable(ability_name, ability_to_perform)
      worker.enable(ability_name, gearup_ability_for(ability_to_perform))
    end

    def use(middleware, *dependencies)
      @middleware.unshift middleware
      @dependencies.unshift dependencies
    end

    def using_middleware?(middleware)
      @middleware.include? middleware
    end

    private

    def gearup_ability_for(ability)
      @middleware.
        zip(@dependencies).
        reduce(ability) do |stack, (middleware_class, dependencies)|
        middleware_class.new(stack, *dependencies)
      end
    end

  end
end
