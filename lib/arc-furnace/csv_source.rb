require 'arc-furnace/source'
require 'arc-furnace/csv_to_hash_with_duplicate_headers'
require 'csv'

module ArcFurnace
  class CSVSource < Source
    include CSVToHashWithDuplicateHeaders
    private_attr_reader :csv, :file
    attr_reader :value

    def initialize(filename: , encoding: 'UTF-8')
      @file = File.open(filename, encoding: encoding)
      @csv = CSV.new(file, encoding: encoding, headers: true).each
      advance
    end

    # Is this source empty?
    def empty?
      !value
    end

    def advance
      @value =
        begin
          csv_to_hash_with_duplicates(csv.next) if csv
        rescue StopIteration
          file.close
          @csv = nil
          nil
        end
    end
  end
end
