require 'gearman'
require 'ostruct'

module Gearup
  module RunsTasksApi

    class NothingCaptured ; end

    class CurrentTask < OpenStruct

      def failed?
        failed
      end

      def retried?
        retried
      end

      def completed?
        completed
      end

    end

    def establish_current_task(task_name, data)
      support = File.dirname(__FILE__)
      log = File.join(support, '..', '..', 'log', 'client.log')
      logger = Logger.new(log)

      Gearman::Util.logger = logger
      client = Gearman::Client.new(@test_gearman_servers)
      client.task_create_timeout_sec = 1
      taskset = Gearman::TaskSet.new(client)
      task = Gearman::Task.new(task_name, data)

      @current_task = CurrentTask.new(
        :task => task,
        :completed => false,
        :failed => false,
        :retried => false,
        :exception => NothingCaptured,
        :number_of_retries => 0,
        :statuses => [],
        :warning => NothingCaptured,
        :on_complete => NothingCaptured,
        :data => NothingCaptured
      )

      task.on_complete do |data|
        logger.debug "Task completed with #{data}"

        @current_task.completed = true
        @current_task.on_complete = data
      end

      task.on_fail do
        logger.debug "Task failed"

        @current_task.failed = true
      end

      task.on_retry do |number_of_retries|
        logger.debug "Task will be retried"

        @current_task.retried = true
        @current_task.number_of_retries = number_of_retries
      end

      task.on_exception do |exception|
        logger.debug "Task raised an exception"

        @current_task.exception = exception
      end

      task.on_status do |numerator, denominator|
        logger.debug "Task updated: #{numerator}/#{denominator}"

        @current_task.statuses << [numerator, denominator]
      end

      task.on_warning do |warning|
        logger.debug "Task warning: #{warning}"

        @current_task.warning = warning
      end

      task.on_data do |data|
        logger.debug "Task yielded data: #{data}"

        @current_task.data = data
      end

      taskset.add_task(task)
      taskset.wait
    end

    def current_task
      @current_task
    end

    def captured_on_complete
      @current_task.on_complete
    end

  end
end
