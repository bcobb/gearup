Feature: Run a worker

  Gearup supplies a binary, `gearup`, that starts workers.

  Scenario: run `gearup` with a specified worker file
    Given a file named "worker.rb" with:
      """
      module Example
        class Echo

          def call(payload)
            return payload.data
          end

        end
      end
      """
    When I successfully run `gearup worker.rb`
    And I run the example.echo task with "hello"
    Then the task should complete with "hello"
