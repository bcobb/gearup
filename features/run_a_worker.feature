Feature: Run a worker

  Gearup supplies a binary, `gearup`, that starts workers.

  Scenario: run `gearup` with a specified worker file
    Given a file named "worker.rb" with:
      """
      module Test
        class Echo

          def work(payload)
            return payload.data
          end

        end
      end

      enable Test::Echo.new
      """
    When I run the test.echo task with "hello"
    And I successfully run `gearup worker.rb`
    Then the task should complete with "hello"
