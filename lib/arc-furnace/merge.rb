require 'arc-furnace/source'

module ArcFurnace
  class Merge < Source

    private_attr_reader :sources

    def initialize(sources:)
      @sources = sources
    end

    def advance
      sources.first.advance
    end

    def value
      value = sources.map(&:value).compact
      return unless value.present?
      value.map(&:deep_dup).reduce({}, :merge)
    end

  end
end
