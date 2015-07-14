require 'arc-furnace/transform'

module ArcFurnace
  class BlockTransform < Transform
    private_attr_reader :block

    def initialize(source:, block:)
      super(source: source)
      @block = block
    end

    def transform(row)
      block.call(row)
    end

  end
end
