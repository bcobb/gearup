module Gearup
  class Middleware

    def initialize(middleware_class, *dependencies)
      @middleware_class = middleware_class
      @dependencies = dependencies
    end

    def wrapping(ability)
      @middleware_class.new(ability, *@dependencies)
    end

  end
end
