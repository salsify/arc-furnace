require 'arc-furnace/csv_to_hash_with_duplicate_headers'
require 'arc-furnace/enumerator_source'
require 'csv'

module ArcFurnace
  class CSVSource < EnumeratorSource
    include CSVToHashWithDuplicateHeaders

    attr_reader :value, :file, :csv, :delimiter

    COMMA = ','.freeze

    def initialize(filename: nil, csv: nil, encoding: 'UTF-8', delimiter: COMMA)
      @file = File.open(filename, encoding: encoding) if filename
      @csv = csv
      @delimiter = delimiter
      super()
    end

    def finalize
      file.close if file
    end

    def build_enumerator
      Enumerator.new do |yielder|
        (csv ? csv : CSV.new(file, { headers: true, col_sep: delimiter })).each do |row|
          yielder << csv_to_hash_with_duplicates(row)
        end
      end
    end
  end
end
