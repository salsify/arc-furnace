require 'arc-furnace/source'

module ArcFurnace
  class ErrorHandler

    # Called during a join operation when a source row is missing a value for the join key.
    def missing_join_key(source_row:, node_id:)
      # nothing
    end

    # Called during a join operation when the hash is missing a vlue for the join key.
    def missing_hash_key(key:, source_row:, node_id:)
      # nothing
    end

    # Called when a hash node is missing a primary key during the build process.
    def missing_primary_key(source_row:, node_id:)
      # nothing
    end

    # Called when a hash node has duplicate source rows
    def duplicate_primary_key(duplicate_row:, key:, node_id:)
      # nothing
    end

  end
end
