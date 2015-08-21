module ArcFurnace
  class Hash
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
          hash[key] = row
        end
      end
    end

    def get(primary_key)
      hash[primary_key]
    end

  end
end
