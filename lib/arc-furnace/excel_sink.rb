require 'arc-furnace/sink'

module ArcFurnace
  class ExcelSink < Sink
    private_attr_reader :filename, :fields, :package, :workbook, :worksheet

    def initialize(filename: , fields:)
      @filename = filename
      @fields = fields
      @package = Axlsx::Package.new
      @workbook = package.workbook
      @worksheet = workbook.add_worksheet(name: 'Sheet1')
      worksheet.add_row(fields)
    end

    def finalize
      package.serialize(filename)
    end

    def row(hash)
      worksheet.add_row(fields.map { |field_id| hash[field_id] })
    end
  end
end
