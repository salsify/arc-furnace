require 'arc-furnace/source'
require 'arc-furnace/csv_to_hash_with_duplicate_headers'
require 'csv'

module ArcFurnace
  class MultiCSVSource < Source
    include CSVToHashWithDuplicateHeaders
    private_attr_reader :csv, :file, :filenames, :encoding
    attr_reader :value

    def initialize(filenames: , encoding: 'UTF-8')
      @encoding = encoding
      @filenames = filenames.reverse
      open_next_file
    end

    # Is this source empty?
    def empty?
      !value
    end

    def advance
      advance_in_current_file || open_next_file
    end

    private

    def advance_in_current_file
      @value =
          begin
            csv_to_hash_with_duplicates(csv.next)
          rescue StopIteration
            nil
          end
      value
    end

    def open_next_file
      file.close if file
      @file = nil
      if filenames.empty?
        nil
      else
        @file = File.open(filenames.pop, encoding: encoding)
        @csv = CSV.new(file, encoding: encoding, headers: true).each
        advance_in_current_file || open_next_file
      end
    end
  end
end
