module Example
  class Reverse

    def call(payload)
      payload.data.reverse
    end

  end
end

enable Example::Reverse.new
