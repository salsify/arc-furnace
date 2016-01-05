require 'arc-furnace/enumerator_source'
require 'roo'

module ArcFurnace
  class ExcelSource < EnumeratorSource

    private_attr_reader :excel, :enumerator
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

    def build_enumerator
      header_row = excel.row(1)

      last_row_index = excel.last_row
      current_row_index = 2

      Enumerator.new do |yielder|
        until current_row_index > last_row_index
          row = header_row.each_with_object(::Hash.new).each_with_index do |(header, result), index|
            value = excel.cell(current_row_index, index + 1)
            coerced_value = (value.is_a?(String) ? value : excel.excelx_value(current_row_index, index + 1)).try(:to_s).try(:strip)
            result[header] = coerced_value unless coerced_value.blank?
          end
          current_row_index += 1
          yielder << row
        end
      end
    end
  end
end
