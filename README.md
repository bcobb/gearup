# Gearup

## What is Gearup?

Gearup provides a Rack-like interface for Gearman workers. Like Rack, it provides a binary, `gearup` to run workers, which are conventionally specified in a file named `config.gu`. A simple `config.gu` might look like this:

```ruby
require 'echo'
require 'lib/worker_logger'

# Log each job using the WorkerLogger
use Gearup::CommonLogger, WorkerLogger.new

# Unpack the data given to each job from JSON
use Gearup::UnpackJSON

# Report exceptions to Airbrake
use Gearup::NotifyAirbrake

# Run the Echo worker
run Echo.new
```

## Worker

Workers respond to `call`, and are given one argument, `data`. The Echo worker above might look like this:

```ruby
class Echo

  def call(data)
    return data
  end

end
```

## Middleware

Gearup workers are supported by middleware, which have access to the worker, as well as the data given to the worker. [gearman-ruby] provides an API through which workers can send data back to the Gearman server, but I haven't decided if Gearup will expose this API yet, as it hasn't proven terribly useful in production.

For instance, the `Gearup::UnpackJSON` middleware uses the [json] gem to convert the data from JSON before it's passed to the worker, and looks roughly like so:

```ruby
require 'json'

module Gearup
  class UnpackJSON

    def initialize(worker)
      @worker = worker
    end

    def call(data)
      json = ::JSON.parse(data)

      @worker.call(json)
    end

  end
end
```

[gearman-ruby]: http://rubgems.org/gems/gearman-ruby
[json]: http://rubygems.org/gems/json
