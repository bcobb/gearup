# Gearup

## What is Gearup?

Gearup provides a Rack-like interface for Gearman workers. Like Rack, it provides a binary, `gearup` to run workers, which are conventionally specified in a file named `worker.rb`. A simple `worker.rb` might look like this:

```ruby
require 'gearup/echo'

# Unpack the data given to each job from JSON
use Gearup::Middleware::UnpackJSON

# The worker has the Echo ability
enable Gearup::Echo.new
```

## Abilities

Abilities respond to `call`, and are given one argument, `payload`. The Echo ability above might look like this:

```ruby
module Gearup
  class Echo

    def call(payload)
      return payload.data
    end

  end
end
```

An application using the worker specified above could send jobs to it using the ability `"gearup.echo"`.

## Middleware

Gearup workers are supported by middleware, which have access to the current ability, as well as the `payload` given to the ability, which includes the `data` given by the server. [gearman-ruby] provides an API through which workers can send data back to the Gearman server, but I haven't decided if Gearup will expose this API yet, as it hasn't proven terribly useful in production.

For instance, the `Gearup::UnpackJSON` middleware uses the [json] gem to convert `payload.data` from JSON before it's passed to the worker, and looks roughly like so:

```ruby
require 'json'

module Gearup
  module Middleware
    class UnpackJSON

      def initialize(ability)
        @ability = ability
      end

      def call(payload)
        payload.data = ::JSON.parse(payload.data)

        @ability.call(payload)
      end

    end
  end
end
```

Note that when adding Middleware to a worker, you may supply arguments to the middleware:

```ruby
module Gearup
  module Middleware
    class Logging

      def initialize(ability, logger)
        @ability = ability
        @logger = logger
      end

      def call(payload)
        @logger.debug "Received: #{payload.data} from server."

        result = @ability.call(payload)

        @logger.debug "Worker returned: #{result}"
      end

    end
  end
end
```

You would use `Gearup::Middleware::Logging` like so:

```ruby
use Gearup::Middleware::Logging, Logger.new('./log/worker.log')

# rest of worker specification
```

# Miscellany

The terminology is in constant flux. Please point out confusing explanations and usage.

[gearman-ruby]: http://rubgems.org/gems/gearman-ruby
[json]: http://rubygems.org/gems/json
[Supervisor]: http://supervisord.org/
[god]: http://godrb.com/
[Foreman]: http://ddollar.github.com/foreman/
