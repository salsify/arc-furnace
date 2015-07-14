require 'arc-furnace/source'

module ArcFurnace
  class Transform < Source

    private_attr_reader :source

    def initialize(source:)
      @source = source
    end

    def prepare
      source.prepare
    end

    def value
      value = source.value.deep_dup
      transform(value) if value
    end

    def transform(row)
      row
    end

    delegate [:empty?, :advance] => :source

  end
end
