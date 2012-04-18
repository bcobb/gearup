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

          def call(env)
            env[:data] = YAML.load(env[:data])

            @ability.call(env)
          end

        end

        class Echo

          def call(env)
            env[:data]
          end

        end
      end

      use Test::FromYaml
      enable 'test.echo', Test::Echo.new
      """
    When I run the test.echo task with "--- :hello"
    Then the task should complete with "hello"

  Scenario: Run a worker that uses middleware which have dependencies
    Given the following worker is running:
      """
      module Test
        class FromSerializedFormat

          def initialize(ability, serializer)
            @ability = ability
            @serializer = serializer
          end

          def call(env)
            env[:data] = @serializer.load(env[:data])

            @ability.call(env)
          end

        end

        class Echo

          def call(env)
            env[:data]
          end

        end
      end

      use Test::FromSerializedFormat, YAML
      enable 'test.echo', Test::Echo.new
      """
    When I run the test.echo task with "--- :hello"
    Then the task should complete with "hello"
