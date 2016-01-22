require 'arc-furnace/source'

# Observe all values in an input stream. All values are passed down
# to the next node un-adultered.
module ArcFurnace
  class Observer < Source
    private_attr_reader :source

    def initialize(source:)
      @source = source
    end

    def value
      value = source.value.deep_dup
      observe(value) if value
      value
    end

    delegate [:empty?, :advance] => :source

    # Observes each row in the node's input stream. This node should not
    # modify the row passed.
    #
    # This method's return value is ignored
    def observe(row)
      raise "Unimplemented"
    end
  end
end
