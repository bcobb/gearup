module Gearup
  class Worker

    SimpleAbility = lambda { |env| }

    attr_reader :ability

    def initialize
      @ability = SimpleAbility
    end

    def enable(ability)
      @ability = ability
    end

    def call(env)
      @ability.call(env)
    end

  end
end
