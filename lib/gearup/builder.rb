module Gearup
  class Builder

    private_class_method :new

    def self.build(&specification)
      builder = new
      builder.instance_exec(&specification)
    end

    def self.build_from_file(file_name)
      file = ::File.expand_path(file_name)
      contents = ::File.read(file)
      command = "Gearup::Builder.build {\n#{contents}}"

      eval command, TOPLEVEL_BINDING, file
    end

    def initialize
      @worker = Worker.new
      @middleware = []
    end

    private

    def enable(worker_ability)
      ability = @middleware.inject(worker_ability) do |ability, middleware|
        middleware.wrapping(ability)
      end

      @worker.enable(ability)
      @worker
    end

    def use(middleware, *args)
      middleware = Gearup::Middleware.new(middleware, *args)

      @middleware.unshift(middleware)
    end

  end
end
