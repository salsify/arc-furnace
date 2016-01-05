require 'arc-furnace/sink'

module ArcFurnace
  # This sink does nothing, nothing!
  class NullSink < Sink

    def initialize(options = {})
      # nothing
    end

    def row(row)
      #nothing
    end

  end
end
