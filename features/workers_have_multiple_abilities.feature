Feature: Workers have multiple abilities

  In practice, a given worker tends to have multiple abilities.

  Scenario: Use a worker's multiple abilities
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

        class Reverse

          def call(data, job)
            return data.to_s.reverse
          end

        end
      end

      use Test::FromYaml
      enable 'test.echo', Test::Echo.new
      enable 'test.reverse', Test::Reverse.new
      """
    When I run the test.echo task with "--- :hello"
    Then the task should complete with "hello"
    When I run the test.reverse task with "--- :hello"
    Then the task should complete with "olleh"
