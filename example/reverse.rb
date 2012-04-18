module Example
  class Reverse

    def call(env)
      env[:data].reverse
    end

  end
end
