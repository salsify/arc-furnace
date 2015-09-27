require 'arc-furnace/abstract_join'

module ArcFurnace
  class OuterJoin < AbstractJoin

    def advance
      @value = source.row
      unless value.nil?
        merge_source_row(value)
      end
    end

  end
end
