require 'gearman'

module Gearup
  module RunsTasksApi

    NothingCaptured = Class.new

    def establish_current_task(task_name, data)
      client = Gearman::Client.new(@test_gearman_servers)
      taskset = Gearman::TaskSet.new(client)
      task = Gearman::Task.new(task_name, data)

      task.on_complete(&capture_on_complete)

      taskset.add_task(task)
    end

    def capture_on_complete
      @on_complete = NothingCaptured

      lambda { |data| @on_complete = data }
    end

    def captured_on_complete
      @on_complete
    end

  end
end
