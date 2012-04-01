Feature: Run a worker

  Gearup supplies a binary, `gearup`, that starts workers.

  Scenario: run `gearup` with a specified worker file
    Given a file named "worker.rb" with:
      """
      module Test
        class Echo

          def call(data, job)
            return data
          end

        end
      end

      enable 'test.echo', Test::Echo.new
      """
    When I successfully run `gearup -l ../../log/test.log -v worker.rb`
    And I run the test.echo task with "hello"
    Then the task should complete with "hello"
