require 'arc-furnace/csv_to_hash_with_duplicate_headers'
require 'arc-furnace/enumerator_source'
require 'csv'

module ArcFurnace
  class CSVSource < EnumeratorSource
    include CSVToHashWithDuplicateHeaders

    attr_reader :value, :file, :csv, :delimiter, :group_by,
      :key_column, :preprocessed_csv

    COMMA = ','.freeze

    def initialize(
      filename: nil,
      csv: nil,
      encoding: 'UTF-8',
      delimiter: COMMA,
      group_by: false,
      key_column: nil
    )
      @file = File.open(filename, encoding: encoding) if filename
      @csv = csv
      @delimiter = delimiter
      @preprocessed_csv = []
      @group_by = group_by
      @key_column = key_column
      super()
    end

    alias_method :group_by?, :group_by

    #
    # note that group_by requires the entire file to be
    # read into memory
    #
    def preprocess
      if group_by?
        parse_file { |row| @preprocessed_csv << csv_to_hash_with_duplicates(row) }
        @preprocessed_csv = @preprocessed_csv.group_by { |row| row[key_column] }
      end
    end

    def finalize
      file.close if file
    end

    def build_enumerator
      Enumerator.new do |yielder|
        if group_by?
          preprocessed_csv.each { |_, array| yielder.yield(array) }
        else
          parse_file { |row| yielder.yield(csv_to_hash_with_duplicates(row)) }
        end
      end
    end

    def parse_file
      (csv ? csv : CSV.new(file, headers: true, col_sep: delimiter)).each { |row| yield row }
    end
  end
end
