require 'arc-furnace/sink'
require 'msgpack'

module ArcFurnace
  class AllFieldsCSVSink < Sink
    private_attr_reader :csv, :fields, :tmp_file, :packer, :fields, :field_mappings

    def initialize(filename: , encoding: 'UTF-8', force_quotes: false)
      @tmp_file = Tempfile.new('intermediate_results', encoding: 'binary')
      @packer = MessagePack::Packer.new(tmp_file)
      @csv = CSV.open(filename, 'wb', encoding: encoding, headers: true, force_quotes: force_quotes)
      @fields = {}
    end

    def finalize
      packer.flush
      tmp_file.rewind

      write_header_row!

      unpacker = MessagePack::Unpacker.new(tmp_file)
      unpacker.each do |hash|
        write_row(hash)
      end

      csv.close
    end

    def row(hash)
      update_field_counts(hash)
      packer.write(hash)
    end

    private

    def write_header_row!
      header_row = []
      fields.each do |key, count|
        count.times { header_row << key }
      end
      csv << header_row
    end

    def write_row(hash)
      row = []
      fields.each do |key, count|
        values = Array.wrap(hash[key.to_s])
        (values.slice(0, count) || []).each do |value|
          row << value
        end
        (count - values.length).times { row << nil }
      end
      csv << row
    end

    def update_field_counts(hash)
      hash.each do |key, values|
        value_count = Array.wrap(values).size
        existing_value_count = fields[key] || 0
        fields[key] = value_count if value_count > existing_value_count
      end
    end
  end
end
