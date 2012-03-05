module Gearup
  class Worker

    SimpleAbility = lambda { |payload| }

    attr_reader :ability

    def initialize
      @ability = SimpleAbility
    end

    def enable(ability)
      @ability = ability
    end

    def work(payload)
      @ability.call(payload)
    end

  end
end
