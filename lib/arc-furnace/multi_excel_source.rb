require 'arc-furnace/enumerator_source'
require 'roo'

module ArcFurnace
  class MultiExcelSource < EnumeratorSource

    private_attr_reader :excels, :enumerator
    attr_reader :value, :excel

    def initialize(filenames: , sheet: nil)
      @excels = filenames.map { |filename| Roo::Excelx.new(filename) }.reverse
      if sheet
        excels.default_sheet = sheet
      end
      super()
    end

    def close
      @excel.close if @excel
    end

    def advance
      advance_in_current_file || open_next_file
    end

    def advance_in_current_file
      @value =
          begin
            enumerator.next if enumerator
          rescue StopIteration
            @enumerator = nil
            nil
          end
      value
    end

    def open_next_file
      excel.close if excel
      @excel = nil
      if excels.empty?
        nil
      else
        @excel = excels.pop
        advance_in_current_file || open_next_file
      end
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
