module ArcFurnace
  class PassthroughSink < Sink

    def initialize(options = {})
    end

    def row(object)
      object
    end

  end
end
