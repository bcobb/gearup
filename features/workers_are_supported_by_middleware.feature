Feature: Workers are supported by middleware

  Gearup's DSL implements `use` to specify middleware used by a worker.

  Scenario: Run a worker that uses a basic middleware
    Given the following worker is running:
      """
      module Test
        class FromYaml

          def initialize(ability)
            @ability = ability
          end

          def call(data, job)
            @ability.call(YAML.load(data), job)
          end

        end

        class Echo

          def call(data, job)
            return data
          end

        end
      end

      use Test::FromYaml
      enable 'test.echo', Test::Echo.new
      """
    When I run the test.echo task with "--- :hello"
    Then the task should complete with "hello"
