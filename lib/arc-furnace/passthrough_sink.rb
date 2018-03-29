module ArcFurnace
  class PassthroughSink < Sink

    def row(anything)
      anything
    end

  end
end
