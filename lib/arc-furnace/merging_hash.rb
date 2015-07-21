module ArcFurnace
  # This allows one to merge multiple rows into one such as:
  #   key, value
  #     1, foo
  #     1, bar
  #     2, baz
  # Results in:
  #   1 => { key => 1, value: [foo, bar] }
  #   2 => { key => 2, value: baz }
  class MergingHash < ::ArcFurnace::Hash
    private_attr_reader :source, :hash

    def prepare
      loop do
        break if source.empty?
        row = source.row
        row_key = row[key_column]
        if row_key
          row_entry = hash[row_key] ||= {}
          row.each do |column, values|
            existing_column_values = row_entry[column]
            if existing_column_values && column != key_column
              if existing_column_values.is_a?(Array)
                existing_column_values.concat(Array.wrap(values))
              else
                new_row_entry = Array.wrap(existing_column_values)
                new_row_entry.concat(Array.wrap(values))
                row_entry[column] = new_row_entry
              end
            else
              unless values.nil?
                row_entry[column] = values.dup
              end
            end
          end
        end
      end
    end

  end
end
