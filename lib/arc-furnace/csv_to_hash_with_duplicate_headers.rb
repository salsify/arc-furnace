module ArcFurnace
  module CSVToHashWithDuplicateHeaders
    def csv_to_hash_with_duplicates(row)
      result = {}
      row.each do |column, value|
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
end