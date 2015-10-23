require 'arc-furnace/source'

# An unfold is the reverse of a fold--it takes a single value an blows it out
# into an enumeration of values. Useful for splitting up rows into multiple output
# rows and whatnot. Only #unfold is required for implementation.
module ArcFurnace
  class Unfold < Source

    private_attr_reader :source, :unfolded

    def initialize(source:)
      @source = source
      @value = nil
    end

    def prepare
      source.prepare
    end

    def value
      if @value.nil? && !empty?
        advance
      end
      @value
    end

    # Given a row from the source, produce the unfolded rows as a result. This method must return
    # an array.
    def unfold(row)
      raise "Unimplemented!"
    end

    def empty?
      @value.nil? && source.empty?
    end

    def advance
      while (unfolded.nil? || unfolded.empty?) && !source.empty?
        # Use reverse since we want to process in-order, but, #pop is much faster than #unshift
        @unfolded = unfold(source.row.deep_dup)
        unfolded.reverse!
      end
      if unfolded && !unfolded.empty?
        @value = unfolded.pop
      else
        @value = nil
      end
    end

  end
end
