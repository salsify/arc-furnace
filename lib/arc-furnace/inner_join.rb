require 'arc-furnace/abstract_join'

module ArcFurnace
  # Perform a join between a hash and a source, only producing rows
  # from the source that match a row from the hash. The resulting row
  # will merge the source "into" the hash, that is, values from the
  # source that share the same keys will overwrite values in the hash
  # value for the corresponding source row.
  #
  # Example:
  # Source row { id: "foo", key1: "boo", key2: "bar" }
  # Matching hash row { id: "foo", key1: "bar", key3: "baz" }
  # Result row: { id: "foo", key1: "boo", key2: "bar", key3: "baz" }
  class InnerJoin < AbstractJoin

    def advance
      loop do
        @value = source.row
        break if @value.nil?
        if merge_source_row(@value)
          break
        end
      end
    end

  end
end
