require 'arc-furnace/sink'

module ArcFurnace
  class ExcelSink < Sink
    private_attr_reader :filename, :fields, :types, :package,
      :workbook, :worksheet

    def initialize(filename: , fields:, types: nil)
      @filename = filename
      @fields = fields
      @package = Axlsx::Package.new
      @workbook = package.workbook
      @worksheet = workbook.add_worksheet(name: 'Sheet1')
      @types = types ? types : []
      worksheet.add_row(fields)
    end

    def finalize
      package.serialize(filename)
    end

    def row(hash)
      worksheet.add_row(fields.map { |field_id| hash[field_id] }, types: types)
    end
  end
end
