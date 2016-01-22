require 'arc-furnace/csv_to_hash_with_duplicate_headers'
require 'arc-furnace/enumerator_source'
require 'csv'

module ArcFurnace
  class CSVSource < EnumeratorSource
    include CSVToHashWithDuplicateHeaders
    attr_reader :value, :file

    def initialize(filename: , encoding: 'UTF-8')
      @file = File.open(filename, encoding: encoding)
      super()
    end

    def finalize
      file.close
    end

    def build_enumerator
      Enumerator.new do |yielder|
        CSV.new(file, headers: true).each { |row| yielder << csv_to_hash_with_duplicates(row) }
      end
    end
  end
end
