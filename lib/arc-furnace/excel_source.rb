require 'arc-furnace/enumerator_source'
require 'roo'

module ArcFurnace
  class ExcelSource < EnumeratorSource

    private_attr_reader :excel, :header_row
    attr_reader :value

    def initialize(filename: , sheet: nil)
      @excel = Roo::Excelx.new(filename)
      if sheet
        excel.default_sheet = sheet
      end
      super()
    end

    def close
      @excel.close if @excel
    end

    def preprocess
      enumerator.next
    end

    def extract_cell_value(cell)
      if cell
        coerced_value = cell.type == :string ? cell.value : cell.excelx_value.try(:to_s).try(:strip)
        coerced_value unless coerced_value.blank?
      end
    end

    def build_enumerator
      Enumerator.new do |yielder|
        excel.each_row_streaming do |row|
          yielder <<
              if header_row
                row.each_with_object({}) do |cell, result|
                  value = extract_cell_value(cell)
                  result[header_row[cell.coordinate.column - 1]] = value if value
                end
              else
                # First time, return the header row so we can save it.
                @header_row = row.map { |value| extract_cell_value(value) }
              end
        end
      end
    end
  end
end
