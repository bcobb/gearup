module Gearup
  class Builder

    def self.build_from_file(file)
      builder = new

      builder.instance_eval(::File.read(file))
      builder.worker
    end

    attr_reader :worker

    def initialize(worker_to_be_built = Worker.new)
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
