require 'arc-furnace/sink'

module ArcFurnace
  class EAVSink < CSVSink

    EAV_HEADERS = [
      :product_id,
      :property_id,
      :property_value
    ].freeze

    private_attr_reader :product_id_property

    def initialize(filename:, encoding: 'UTF-8', force_quotes: false, product_id_property:)
      @csv = CSV.open(filename, 'wb', encoding: encoding, headers: true, force_quotes: force_quotes)
      @product_id_property = product_id_property
      csv << EAV_HEADERS
    end

    def row(product)
      product_id = product[product_id_property]

      product.each do |property, value|
        csv << [ product_id, property, value ]
      end
    end

  end
end
