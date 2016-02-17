require 'arc-furnace/source'
require 'roo'

module ArcFurnace
  class MultiExcelSource < Source

    private_attr_reader :enumerator, :header_row
    attr_reader :value, :excel, :sheets_info_array
    
    # Sheets is in the format of:
    # [
    #   { filename: 'foo.xlsx', sheet: 'sheet name' },
    #   { filename: 'foo2.xlsx', sheet: 'sheet name' }
    # ]
    #
    # The value for the :sheet key points to the sheet that we want to parse.
    # If sheets are not explicitly indicated, they will not be parsed.

    def initialize(sheets_info_array: [])
      @sheets_info_array = sheets_info_array.reverse
      open_next_file
    end

    private

    def preprocess
      enumerator.next
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
      @header_row = nil
      if sheets_info_array.empty?
        nil
      else
        sheets_info = sheets_info_array.pop
        @excel = Roo::Excelx.new(sheets_info[:filename])
        @excel.default_sheet = sheets_info[:sheet]
        @enumerator = build_enumerator
        preprocess
        advance
      end
    end

    def extract_cell_value(cell)
      if cell
        coerced_value = cell.type == :string ? cell.value : cell.cell_value.try(:to_s).try(:strip)
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
