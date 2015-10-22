require 'arc-furnace/filter'

module ArcFurnace
  class BlockFilter < Filter
    private_attr_reader :block

    def initialize(source:,filter_param:, block:)
      raise 'Must specify a block' if block.nil?
      @block = block
      super(source: source, filter_param: filter_param)
    end

    def filter(row)
      block.call(row)
    end

  end
end
