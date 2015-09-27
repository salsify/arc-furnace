require 'csv'

module CSVDuplicateHeaderColumnPatch
  def to_hash_with_duplicates
    result = {}
    each do |column, value|
      unless value.nil?
        existing_value = result[column]
        result[column] =
          if existing_value
            Array.wrap(existing_value) + [ value ]
          else
            value
          end
      end
    end
    result
  end
end

CSV::Row.include(CSVDuplicateHeaderColumnPatch)
