require 'arc-furnace/node'

module ArcFurnace
  class Hash < Node
    attr_reader :key_column
    private_attr_reader :source, :hash

    def initialize(source: , key_column:)
      @source = source
      @key_column = key_column
      @hash = {}
    end

    # Pass a block that accepts two argument, the join key
    # for each value and the value
    def each(&block)
      hash.each(&block)
    end

    def prepare
      loop do
        break if source.empty?
        row = source.row
        key = row[key_column]
        if key
          if hash.include?(key)
            error_handler.duplicate_primary_key(duplicate_row: row, key: key, node_id: node_id)
          end
          hash[key] = row
        else
          error_handler.missing_primary_key(source_row: row, node_id: node_id)
        end
      end
    end

    def get(primary_key)
      hash[primary_key]
    end

  end
end
