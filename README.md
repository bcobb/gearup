# Gearup

## What is Gearup?

Gearup builds [Gearman] workers around a Middleware stack. It provides a binary, `gearup` to run workers, which are conventionally specified in a file named `worker.rb`. A simple `worker.rb` might look like this:

```ruby
# worker.rb

require 'gearup/echo'

# Load the data given to each job from JSON, and return it as a JSON string
use Gearup::Hypothetical::JSON

# The worker has the 'echo' ability and the 'reverse' ability
enable 'echo', Gearup::Echo.new
enable 'reverse', Gearup::Reverse.new
```

You can run it on `localhost:4730` like so: `gearup worker.rb`. See `gearup --help` for the command line options.

## Why Middleware?

Structuring a worker as a set of abilities, each supported by a chain of middleware separates the concerns of the actual work to be performed from its dependencies and auxiliary services. The process of building a worker provides natural places to configure each, so that each middleware can be written in a reusable way.

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

* Provide a base set of useful middleware.
* Client middleware?

# Miscellany

The terminology has been in constant flux. Please point out confusing explanations and usage.

[Gearman]: http://gearman.org
[gearman-ruby]: http://rubgems.org/gems/gearman-ruby
[json]: http://rubygems.org/gems/json
[Supervisor]: http://supervisord.org/
[god]: http://godrb.com/
[Foreman]: http://ddollar.github.com/foreman/
