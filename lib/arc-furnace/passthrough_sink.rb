module ArcFurnace
  class PassthroughSink < Sink

    attr_reader :collection

    def initialize(options = {})
      @collection = Set.new
    end

    def finalize
      collection.to_a
    end

    def row(object)
      collection << object
    end

  end
end
