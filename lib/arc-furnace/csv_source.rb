require 'arc-furnace/source'
require 'csv'

module ArcFurnace
  class CSVSource < Source
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
          csv.next.to_hash_with_duplicates if csv
        rescue StopIteration
          file.close
          @csv = nil
          nil
        end
    end
  end
end
