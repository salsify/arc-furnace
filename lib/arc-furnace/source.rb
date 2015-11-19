require 'arc-furnace/node'

module ArcFurnace
  class Source < Node
    extend Forwardable

    # Called to prepare anything this source needs to do before providing rows.
    # For instance, opening a source file or database connection.
    def prepare

    end

    # Advance this source by one, returning the row as a hash
    def row
      result = value
      advance
      result
    end

    # Called at the end of processing, do any clean-up or state-saving here.
    def finalize

    end

    # Is this source empty?
    def empty?
      raise 'Unimplemented'
    end

    # The current value this source points at
    # This is generally the only method required to implement a source.
    def value
      raise 'Unimplemented'
    end

    # Close the source. Called by the framework at the end of processing.
    def close

    end

    # Advance this source by one. #advance specifies no return value contract
    def advance
      raise 'Unimplemented'
    end

  end
end
