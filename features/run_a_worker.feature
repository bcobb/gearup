Feature: Run a worker

  Gearup supplies a binary, `gearup`, that starts workers.

  Scenario: run `gearup` with a specified worker file
    Given the following worker is running:
      """
      module Test
        class Echo

          def call(env)
            env[:data]
          end

        end
      end

      enable 'test.echo', Test::Echo.new
      """
    When I run the test.echo task with "hello"
    Then the task should complete with "hello"
