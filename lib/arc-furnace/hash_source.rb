require 'arc-furnace/enumerator_source'

module ArcFurnace
  class HashSource < ArcFurnace::EnumeratorSource

    attr_reader :hashes

    # expects an array of hashes
    def initialize(hashes:)
      @hashes = hashes
      super()
    end

    def build_enumerator
      Enumerator.new do |yielder|
        hashes.each { |hash| yielder.yield(hash) }
      end
    end

  end
end
