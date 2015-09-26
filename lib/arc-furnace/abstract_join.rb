require 'arc-furnace/source'

module ArcFurnace
  class AbstractJoin < Source
    private_attr_reader :hash, :source, :key_column
    attr_reader :value

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

    def prepare
      advance
    end

    def advance
      raise "Unimplemented!"
    end

    delegate empty?: :source

    protected

    def merge_source_row(source_row)
      if hash_value = hash.get(source_row[key_column])
        hash_value = hash_value.deep_dup
        source_row.each do |key, value|
          hash_value[key] = value
        end
        @value = hash_value
        true
      else
        false
      end
    end

  end
end
