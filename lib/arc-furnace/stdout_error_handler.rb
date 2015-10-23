require 'arc-furnace/error_handler'

module ArcFurnace
  class StdoutErrorHandler < ErrorHandler

    # Called during a join operation when a source row is missing a value for the join key.
    def missing_join_key(source_row:, node_id:)
      puts "Missing join key in #{source_row} for #{node_id}"
    end

    # Called during a join operation when the hash is missing a value for the join key.
    def missing_hash_key(key:, source_row:, node_id:)
      puts "Missing hash key '#{key}' in join for #{node_id}"
    end

    # Called when a hash node is missing a primary key during the build process.
    def missing_primary_key(source_row:, node_id:)
     puts "Missing primary key in '#{source_row}' for #{node_id}"
    end

    # Called when a hash node has duplicate source rows
    def duplicate_primary_key(duplicate_row:, key:, node_id:)
      puts "Duplicate primary key in '#{duplicate_row}' for key '#{key}' in #{node_id}"
    end

  end
end
