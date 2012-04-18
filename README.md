# Gearup

## What is Gearup?

Gearup provides a Rack-like interface for Gearman workers. Like Rack, it provides a binary, `gearup` to run workers, which are conventionally specified in a file named `worker.rb`. A simple `worker.rb` might look like this:

```ruby
require 'gearup/echo'

# Load the data given to each job from JSON, and return it as a JSON string
use Gearup::Hypothetical::JSON

# The worker has the Echo ability
enable Gearup::Echo.new
```

## Abilities

Abilities respond to `call`, and are given one argument, `env`. The Echo ability above might look like this:

```ruby
module Gearup
  class Echo

    def call(env)
      env[:data]
    end

  end
end
```

An application using the worker specified above could send jobs to it using the ability `"gearup.echo"`.

## Middleware

Gearup workers are supported by middleware, which have access to the current ability, as well as the `env` given to the ability, which includes the `data` given by the server. [gearman-ruby] provides an API through which workers can send data back to the Gearman server, but I haven't decided if Gearup will do anything more than provide it as the value of `env[:job]`, as it hasn't proven terribly useful in production.

Any sane middleware should call `@ability.call(env)` at some point. Unlike Rack, there are not (yet) any expectations as to the return values of middleware and abilities. The return value from performing the ability will be passed back to the server as a string.

For instance, the hypothetical `Gearup::JSON` middleware uses the [json] gem to convert `env[:data]` from JSON before it's passed to the worker, and to dump the result as JSON after the worker has performed the ability. It would look roughly like so:

```ruby
require 'json'

module Gearup
  module Hypothetical
    class JSON

      def initialize(ability)
        @ability = ability
      end

      def call(env)
        env[:data] = ::JSON.load(env[:data])

        ::JSON.dump(@ability.call(env))
      end

    end
  end
end
```

Note that when adding Middleware to a worker, you may supply arguments to the middleware:

```ruby
module Gearup
  module Hypothetical
    class Logging

      def initialize(ability, logger)
        @ability = ability
        @logger = logger
      end

      def call(env)
        @logger.debug "Received: #{env[:data]} from server."

        result = @ability.call(env)

        @logger.debug "Worker returned: #{result}"

        result
      end

    end
  end
end
```

You would use `Gearup::Hypothetical::Logging` like so:

```ruby
use Gearup::Hypothetical::Logging, Logger.new('./log/worker.log')

# rest of worker specification
```

# TODO

* Address the occasional bug where gearup tries to shutdown, but GearmanRuby does this: `Server localhost:4730 timed out or lost connection (#<SystemExit: exit>); marking bad`
* Provide a better way than adding keys to the `env` hash to pass data and middleware-provided methods down the stack 
* Remove -D and -l in favor of letting other tools ([god], [Supervisor], e.g.) handle daemonization and redirecting STDOUT to a log file or service. The only thing blocking this are the cucumber tests, which need to run a daemonized worker and stop it. I have not been able to get [god] to do this.
* Provide a base set of useful middleware.
* Client middleware?

# Miscellany

The terminology has been in constant flux. Please point out confusing explanations and usage.

[gearman-ruby]: http://rubgems.org/gems/gearman-ruby
[json]: http://rubygems.org/gems/json
[Supervisor]: http://supervisord.org/
[god]: http://godrb.com/
[Foreman]: http://ddollar.github.com/foreman/
