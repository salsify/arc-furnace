require 'arc-furnace/source'

module ArcFurnace
  class AbstractJoin < Source
    private_attr_reader :hash, :source, :key_column

    # The source is a source, the hash is a hash, and one can optionally
    # pass the key column to get the primary key for each source entity, the
    # default is equijoin semantics--the key of the hash is used.
    def initialize(source: , hash:, key_column: nil)
      if source.is_a?(::ArcFurnace::Source) && hash.is_a?(::ArcFurnace::Hash)
        @hash = hash
        @source = source
        @key_column = key_column || hash.key_column
      else
        raise 'Must be passed one Hash and one Source!'
      end
    end

    def value
      if @value.nil? && !empty?
        advance
      end
      @value
    end

    def advance
      raise "Unimplemented!"
    end

    delegate empty?: :source

    protected

    def merge_source_row(source_row)
      key = source_row[key_column]
      if key
        if hash_value = hash.get(key)
          hash_value = hash_value.deep_dup
          source_row.each do |key, value|
            hash_value[key] = value
          end
          @value = hash_value
          true
        else
          error_handler.missing_hash_key(source_row: source_row, key: key, node_id: node_id)
          false
        end
      else
        error_handler.missing_join_key(source_row: source_row, node_id: node_id)
      end
    end

  end
end
