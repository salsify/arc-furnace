require 'eigenclass'
require 'arc-furnace/nodes'
require 'arc-furnace/error_handler'

module ArcFurnace
  class Pipeline

    eattr_accessor :sink_node, :sink_source, :intermediates_map
    @intermediates_map = {}

    # Ensure that subclasses don't overwrite the parent's transform
    # node definitions
    def self.inherited(subclass)
      subclass.intermediates_map = intermediates_map.dup
    end

    # Define the sink for this transformation. Only a single sink may be
    # specified per transformation. The sink is delivered a hash per row or
    # entity, and feeds them from the graph of nodes above it.
    def self.sink(type: , source:, params:)
      if sink_node
        raise 'Sink already defined!'
      end

      @sink_node = -> do
        type.new(resolve_parameters(params))
      end
      @sink_source = source
    end

    # Define a hash node, processing all rows from it's source and caching them
    # in-memory.
    def self.hash_node(name, type: ArcFurnace::Hash, params:)
      define_intermediate(name, type: type, params: params)
    end

    # A source that has row semantics, delivering a hash per row (or per entity)
    # for the source.
    def self.source(name, type:, params:)
      raise "Source #{type} is not a Source!" unless type <= Source
      define_intermediate(name, type: type, params: params)
    end

    # Define an inner join node where rows from the source are dropped
    # if an associated entity is not found in the hash for the join key
    def self.inner_join(name, type: ArcFurnace::InnerJoin, params:)
      define_intermediate(name, type: type, params: params)
    end

    # Define an outer join nod  e where rows from the source are kept
    # even if an associated entity is not found in the hash for the join key
    def self.outer_join(name, type: ArcFurnace::OuterJoin, params:)
      define_intermediate(name, type: type, params: params)
    end

    # Define a node that transforms rows. By default you get a BlockTransform
    # (and when this metaprogramming method is passed a block) that will be passed
    # a hash for each row. The result of the block becomes the row for the next
    # downstream node.
    def self.transform(name, type: BlockTransform, params: {}, &block)
      if block
        params[:block] = block
      end
      raise "Transform #{type} is not a Transform!" unless type <= Transform
      define_intermediate(name, type: type, params: params)
    end

    # Define a node that unfolds rows. By default you get a BlocUnfold
    # (and when this metaprogramming method is passed a block) that will be passed
    # a hash for each row. The result of the block becomes the set of rows for the next
    # downstream node.
    def self.unfold(name, type: BlockUnfold, params: {}, &block)
      if block
        params[:block] = block
      end
      raise "Unfold #{type} is not an Unfold!" unless type <= Unfold
      define_intermediate(name, type: type, params: params)
    end

    # Create an instance to run a transformation, passing the parameters to
    # instantiate the transform instance with. The resulting class instance
    # will have a single public method--#execute, which will perform the
    # transformation.
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
      attr_reader :sink_node, :sink_source, :intermediates_map, :params, :dsl_class, :error_handler

      def initialize(dsl_class, error_handler: ErrorHandler.new, **params)
        @dsl_class = dsl_class
        @params = params
        @intermediates_map = {}
        @error_handler = error_handler
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
        intermediates_map.each do |node_id, instance|
          instance.error_handler = error_handler
          instance.node_id = node_id
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
