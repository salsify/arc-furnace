require 'arc-furnace/source'

module ArcFurnace
  class EnumeratorSource < Source

    private_attr_reader :enumerator
    attr_reader :value

    def initialize
      @enumerator = build_enumerator
      preprocess
      advance
    end

    # Called after setting up the enumerator but before advancing it
    # Use this to extract header rows for instance.
    def preprocess
      # nothing
    end

    # Is this source empty?
    def empty?
      !value
    end

    def advance
      @value =
        begin
          enumerator.next if enumerator
        rescue StopIteration
          @enumerator = nil
          nil
        end
    end

    protected

    # Return the enumerator
    def build_enumerator
      raise "Unimplemented"
    end
  end
end
