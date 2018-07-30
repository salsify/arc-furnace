require 'arc-furnace/enumerator_source'

module ArcFurnace
  class ArraySource < ArcFurnace::EnumeratorSource

    attr_reader :array

    # expects an array of array
    def initialize(array:)
      @array = array
      super()
    end

    def build_enumerator
      Enumerator.new do |yielder|
        array.each { |hash| yielder.yield(hash) }
      end
    end

  end
end
