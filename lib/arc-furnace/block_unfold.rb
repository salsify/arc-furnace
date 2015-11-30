require 'arc-furnace/unfold'

module ArcFurnace
  class BlockUnfold < Unfold
    private_attr_reader :block

    def initialize(source:, block:)
      raise 'Must specify a block' if block.nil?
      @block = block
      super(source: source)
    end

    def unfold(row)
      if block.arity == 2
        block.call(row, params)
      else
        block.call(row)
      end
    end

  end
end
