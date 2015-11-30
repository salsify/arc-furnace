require 'arc-furnace/filter'

module ArcFurnace
  class BlockFilter < Filter
    private_attr_reader :block

    def initialize(source:, block:)
      raise 'Must specify a block' if block.nil?
      @block = block
      super(source: source)
    end

    def filter(row)
      if block.arity == 2
        block.call(row, params)
      else
        block.call(row)
      end
    end

  end
end
