require 'arc-furnace/abstract_join'

module ArcFurnace
  class OuterJoin < AbstractJoin

    def advance
      @value = source.row
      merge_source_row(value) unless value.nil?
    end

  end
end
