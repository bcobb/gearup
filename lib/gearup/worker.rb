module Gearup
  class Worker

    def initialize(servers = Gearup.servers)
      # XXX: abstract this into a few objective-based settings
      # e.g. lazy-in-between-jobs, checks-frequently, etc.
      worker_options = { :network_timeout_sec => 2, :reconnect_sec => 4 }

      @worker = Gearman::Worker.new(servers, worker_options)
      @abilities = []
    end

    def work
      @worker.work
    end

    def enable(ability_name, &ability)
      return if able_to_perform?(ability_name)

      ability ||= Proc.new { }

      @abilities << ability_name

      @worker.add_ability(ability_name, &ability)
      @worker.after_ability(ability_name, &debug_after_ability(ability_name))
    end

    def disable(ability_name)
      return unless able_to_perform?(ability_name)

      @abilities.delete(ability_name)

      @worker.remove_ability(ability_name)
    end

    def shutdown
      @worker.worker_enabled = false
      @abilities.each { |ability| disable ability }
    end

    def able_to_perform?(ability_name)
      @abilities.include?(ability_name)
    end

    private

    def debug_after_ability(ability)
      lambda do |result, data|
        logger.debug "After #{ability}(#{data}), got #{result}"
      end
    end

    def logger
      Gearup.logger
    end

  end
end
