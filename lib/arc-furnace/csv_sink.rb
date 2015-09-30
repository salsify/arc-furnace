require 'arc-furnace/sink'

module ArcFurnace
  class CSVSink < Sink
    private_attr_reader :csv, :fields

    def initialize(filename: , fields: , encoding: 'UTF-8', force_quotes: false)
      @csv = CSV.open(filename, 'wb', encoding: encoding, headers: true, force_quotes: force_quotes)
      @fields = fields
      csv << fields
    end

    def finalize
      csv.close
    end

    def row(hash)
      csv << fields.map { |field_id| hash[field_id] }
    end
  end
end
