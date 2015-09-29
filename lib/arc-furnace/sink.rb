module ArcFurnace
  class Sink

    # The only required method to implement. #row is called for each output row and
    # a sink must handle each.
    def row(row)
      raise "Unimplemented!"
    end

    # Handle any pre-processing here.
    def prepare

    end

    # If the sink needs to perform any clean-up (closing file handles, etc),
    # do it here.
    def finalize

    end
  end
end
