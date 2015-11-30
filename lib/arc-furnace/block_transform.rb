require 'arc-furnace/transform'

module ArcFurnace
  class BlockTransform < Transform
    private_attr_reader :block

    def initialize(source:, block:)
      raise 'Must specify a block' if block.nil?
      @block = block
      super(source: source)
    end

    def transform(row)
      if block.arity == 2
        block.call(row, params)
      else
        block.call(row)
      end
    end

  end
end
