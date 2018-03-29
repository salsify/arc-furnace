module ArcFurnace
  class PassthroughSink < Sink

    def row(object)
      object
    end

  end
end
