require 'arc-furnace/enumerator_source'

module ArcFurance
  class HashesSource < ArcFurnace::EnumeratorSource

    attr_reader :hashes

    # expectes an array of hashes
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
