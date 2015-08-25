require 'arc-furnace/sink'

module ArcFurnace
  class FixedColumnCSVSink < Sink
    private_attr_reader :fields, :csv

    # Expects filename to a filename to open the csv
    # Expects fields to a hash of Column name => column Width
    def initialize(filename: , fields: , encoding: 'UTF-8', force_quotes: false)
      @csv = CSV.open(filename, 'wb', encoding: encoding, headers: true, force_quotes: force_quotes)
      @fields = fields
      write_header
    end

    def write_header
      csv << fields.each_with_object([]) do |(key, count), result|
        count.times { result << key }
      end
    end

    def finalize
      csv.close
    end

    def row(hash)
      row = []
      fields.each do |column_name, count|
        values = Array.wrap(hash[column_name])
        (values.slice(0, count) || []).each do |value|
          row << value
        end
        (count - values.length).times { row << nil }
      end
      csv << row
    end
  end
end
