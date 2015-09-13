require 'arc-furnace/source'

module ArcFurnace
  class EnumeratorSource < Source

    private_attr_reader :enumerator
    attr_reader :value

    def initialize
      @enumerator = build_enumerator
      advance
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
      raise "Unimplemented!"
    end
  end
end
