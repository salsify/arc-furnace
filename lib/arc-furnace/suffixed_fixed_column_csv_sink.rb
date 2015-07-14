require 'arc-furnace/fixed_column_csv_sink'

module ArcFurnace
  class SuffixedFixedColumnCSVSink < FixedColumnCSVSink
    private_attr_reader :fields

    def write_header
      csv << fields.each_with_object([]) do |(key, count), result|
        if count > 1
          count.times { |index| result << "#{key} #{index + 1}" }
        else
          result << key
        end
      end
    end

  end
end
