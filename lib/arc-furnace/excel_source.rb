require 'arc-furnace/enumerator_source'
require 'roo'

module ArcFurnace
  class ExcelSource < EnumeratorSource

    private_attr_reader :excel, :header_row
    attr_reader :value, :group_by, :key_column

    def initialize(filename:, sheet: nil, group_by: false, key_column: nil)
      @excel = Roo::Excelx.new(filename)
      @preprocessed_excel = []
      @group_by = group_by
      @key_column = key_column
      excel.default_sheet = sheet if sheet
      super()
    end

    alias_method :group_by?, :group_by

    def preprocess
      if group_by?
        build_headers
        group_rows
      else
        enumerator.next
      end
    end

    def build_headers
      @header_row = excel.first
    end

    def group_rows
      @excel.each_row_streaming { |row| @preprocessed_excel << build_row(row) }
      @preprocessed_excel = @preprocessed_excel.group_by { |row| row[key_column] }
    end

    def extract_cell_value(cell)
      if cell
        coerced_value = cell.type == :string ? cell.value : cell.cell_value.try(:to_s).try(:strip)
        coerced_value unless coerced_value.blank?
      end
    end

    def build_row(row)
      row.each_with_object({}) do |cell, result|
        value = extract_cell_value(cell)
        result[header_row[cell.coordinate.column - 1]] = value if value
      end
    end

    def build_enumerator
      Enumerator.new do |yielder|
        if group_by?
          @preprocessed_excel.each.with_index do |(_, array), index|
            next if index == 0 # skip header row
            yielder << array
          end
        else
          excel.each_row_streaming do |row|
            yielder << if header_row
              build_row(row)
            else
              # First time, return the header row so we can save it.
              @header_row = row.map { |value| extract_cell_value(value) }
            end
          end
        end
      end
    end

    def close
      @excel.close if @excel
    end

  end
end
