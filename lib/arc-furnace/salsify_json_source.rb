require 'arc-furnace/enumerator_source'

module ArcFurance
  class SalsifyJSONSource < ArcFurnace::EnumeratorSource

    attr_reader :salsify_json

    def initialize(salsify_json:)
      @salsify_json = salsify_json
      super()
    end

    def build_enumerator
      Enumerator.new do |yielder|
        salsify_json.products.each { |product| yielder.yield(product) }
      end
    end

  end
end
