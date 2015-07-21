require 'arc-furnace/hash'

module ArcFurnace
  # This allows one to merge multiple rows into one such as:
  #   key, attribute, value
  #     1, value1, foo
  #     1, value1, bar
  #     1, value2, baz
  # Results in:
  #   1 => {  value1 => [foo, bar], value2 => baz }
  class BinaryKeyMergingHash < ::ArcFurnace::Hash
    private_attr_reader :source, :hash, :secondary_key, :value_key

    def initialize(source: , primary_key:, secondary_key:, value_key:)
      super(source: source, key_column: primary_key)
      @secondary_key = secondary_key
      @value_key = value_key
    end

    def prepare
      loop do
        break if source.empty?
        row = source.row
        row_key = row[key_column]
        second_key = row[secondary_key]
        value = row[value_key]
        if row_key && second_key && value
          row_entry = hash[row_key] ||= {}
          value_arr = row_entry[second_key] ||= []
          value_arr.concat(Array.wrap(value))
        end
      end
    end

  end
end
