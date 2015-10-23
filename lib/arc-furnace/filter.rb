require 'arc-furnace/source'

# Filters limit rows to downstream nodes. They act just like Enumerable#filter:
# when the #filter method returns true, the row is passed downstream. when
# it returns false, the row is skipped.
module ArcFurnace
  class Filter < Source

    private_attr_reader :source

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
    # Given a row from the source, tell if it should be passed down to the next
    # node downstream from this node.
    #
    # This method must return a boolean
    def filter(row)
      raise "Unimplemented"
    end

    def empty?
      @value.nil? && source.empty?
    end

    def advance
      loop do
        @value = source.row
        break if value.nil? || filter(value)
      end
    end

  end
end
