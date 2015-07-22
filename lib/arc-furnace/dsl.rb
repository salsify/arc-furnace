require 'eigenclass'

module ArcFurnace
  class DSL

    eattr_accessor :sink_node, :sink_source, :intermediates_map

    def self.inherited(subclass)
      subclass.intermediates_map = intermediates_map.dup
    end
    @intermediates_map = {}

    def self.sink(type: , source:, params:)
      if sink_node
        raise 'Sink already defined!'
      end

      @sink_node = -> do
        type.new(resolve_parameters(params))
      end
      @sink_source = source
    end

    def self.hash_node(name, type: ArcFurnace::Hash, params:)
      define_intermediate(name, type: type, params: params)
    end

    def self.source(name, type:, params:)
      raise "Source #{type} is not a Source!" unless type <= Source
      define_intermediate(name, type: type, params: params)
    end

    def self.inner_join(name, type: ArcFurnace::InnerJoin, params:)
      define_intermediate(name, type: type, params: params)
    end

    def self.outer_join(name, type: ArcFurnace::OuterJoin, params:)
      define_intermediate(name, type: type, params: params)
    end

    def self.transform(name, type: BlockTransform, params: {}, &block)
      if block
        params[:block] = block
      end
      raise "Transform #{type} is not a Transform!" unless type <= Transform
      define_intermediate(name, type: type, params: params)
    end

    def self.instance(params = {})
      DSLInstance.new(self, params)
    end

    private

    def self.define_intermediate(name, type:, params:)
      intermediates_map[name] = -> do
        type.new(resolve_parameters(params))
      end
    end

    class DSLInstance
      attr_reader :sink_node, :sink_source, :intermediates_map, :params, :dsl_class

      def initialize(dsl_class, params)
        @dsl_class = dsl_class
        @params = params
        @intermediates_map = {}
      end

      def execute
        build
        prepare
        run
      end

      private

      def run
        while (row = sink_source.row)
          sink_node.row(row)
        end
        sink_node.finalize
      end

      def prepare
        intermediates_map.each do |_, instance|
          instance.prepare
        end
        sink_node.prepare
      end

      def build
        dsl_class.intermediates_map.each do |key, instance|
          intermediates_map[key] = instance_exec(&instance) if instance
        end
        @sink_node = instance_exec(&dsl_class.sink_node)
        @sink_source = intermediates_map[dsl_class.sink_source]
      end

      def resolve_parameters(params_to_resolve)
        params_to_resolve.each_with_object({}) do |(key, value), result|
          result[key] =
            if value.is_a?(Symbol)
              # Allow resolution of intermediates
              resolve_parameter(value)
            elsif value.nil?
              resolve_parameter(key)
            else
              value
            end
        end
      end

      def resolve_parameter(key)
        self.params[key] || self.intermediates_map[key] || (raise "Unknown key #{key}!")
      end

    end
  end
end
