require 'arc-furnace/source'

module ArcFurnace
  class OuterJoin < Source
    private_attr_reader :hash, :source
    attr_reader :value

    def initialize(source: , hash:)
      if source.is_a?(::ArcFurnace::Source) && hash.is_a?(::ArcFurnace::Hash)
        @hash = hash
        @source = source
      else
        raise 'Must be passed one Hash and one Source!'
      end
    end

    def prepare
      hash.prepare
      source.prepare
      advance
    end

    def advance
      loop do
        @value = source.value
        source.advance
        break if value.nil?

        if hash_value = hash.get(value[hash.key_column])
          hash_value = hash_value.deep_dup
          value.each do |key, value|
            hash_value[key] = value
          end
          @value = hash_value
          break
        else
          @value
          break
        end
      end
    end

    delegate empty?: :source
  end
end
