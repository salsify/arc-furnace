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
        type.new(resolve_parameters(:sink, params))
      end
      @sink_source = source
    end

    # Define a hash node, processing all rows from it's source and caching them
    # in-memory.
    def self.hash_node(node_id, type: ArcFurnace::Hash, params:)
      define_intermediate(node_id, type: type, params: params)
    end

    # A source that has row semantics, delivering a hash per row (or per entity)
    # for the source.
    def self.source(node_id, type:, params:)
      raise "Source #{type} is not a Source!" unless type <= Source
      define_intermediate(node_id, type: type, params: params)
    end

    # Define an inner join node where rows from the source are dropped
    # if an associated entity is not found in the hash for the join key
    def self.inner_join(node_id, type: ArcFurnace::InnerJoin, params:)
      define_intermediate(node_id, type: type, params: params)
    end

    # Define an outer join nod  e where rows from the source are kept
    # even if an associated entity is not found in the hash for the join key
    def self.outer_join(node_id, type: ArcFurnace::OuterJoin, params:)
      define_intermediate(node_id, type: type, params: params)
    end

    # Define a node that transforms rows. By default you get a BlockTransform
    # (and when this metaprogramming method is passed a block) that will be passed
    # a hash for each row. The result of the block becomes the row for the next
    # downstream node.
    def self.transform(node_id, type: BlockTransform, params: {}, &block)
      if block_given? && type <= BlockTransform
        params[:block] = block
      end
      raise "Transform #{type} is not a Transform!" unless type <= Transform
      define_intermediate(node_id, type: type, params: params)
    end

    # Define a node that unfolds rows. By default you get a BlockUnfold
    # (and when this metaprogramming method is passed a block) that will be passed
    # a hash for each row. The result of the block becomes the set of rows for the next
    # downstream node.
    def self.unfold(node_id, type: BlockUnfold, params: {}, &block)
      if block_given? && type <= BlockUnfold
        params[:block] = block
      end
      raise "Unfold #{type} is not an Unfold!" unless type <= Unfold
      define_intermediate(node_id, type: type, params: params)
    end

    # Define a node that filters rows. By default you get a BlockFilter
    # (and when this metaprogramming method is passed a block) that will be passed
    # a hash for each row. The result of the block determines if a given row
    # flows to a downstream node
    def self.filter(node_id, type: BlockFilter, params: {}, &block)
      if block_given? && type <= BlockFilter
        params[:block] = block
      end
      raise "Filter #{type} is not a Filter!" unless type <= Filter
      define_intermediate(node_id, type: type, params: params)
    end

    # Create an instance to run a transformation, passing the parameters to
    # instantiate the transform instance with. The resulting class instance
    # will have a single public method--#execute, which will perform the
    # transformation.
    def self.instance(params = {})
      PipelineInstance.new(self, params)
    end

    private

    ALLOWABLE_PARAM_TYPES = [:key, :keyreq].freeze

    def self.define_intermediate(node_id, type:, params:)
      intermediates_map[node_id] = -> do
        resolved_params = resolve_parameters(node_id, params)
        key_parameters = type.instance_method(:initialize).parameters do |param|
          ALLOWABLE_PARAM_TYPES.include?(param.first)
        end.map(&:second)
        # Allow params to be passed that are not in the initializer
        instance = type.new(resolved_params.slice(*key_parameters))
        instance.params = resolved_params
        instance
      end
    end

    class PipelineInstance
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
        intermediates_map.each { |_, instance| instance.finalize }
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
        @sink_node = exec_with_error_handling(&dsl_class.sink_node)
        @sink_source = intermediates_map[dsl_class.sink_source]
      end

      def resolve_parameters(node_id, params_to_resolve)
        params_to_resolve.each_with_object({}) do |(key, value), result|
          result[key] =
            if value.is_a?(Symbol)
              # Allow resolution of intermediates
              resolve_parameter(node_id, value)
            elsif value.nil?
              resolve_parameter(node_id, key)
            else
              value
            end
        end
      end

      def resolve_parameter(node_id, key)
        self.params[key] || self.intermediates_map[key] || (raise "When processing node #{node_id}: Unknown key #{key}!")
      end

      def exec_with_error_handling(&block)
        instance_exec(&block) if block_given?
      rescue CSV::MalformedCSVError
        params = sink_source.params
        raise "File #{find_root_source(params).file.path} cannot be processed."
      end

      def find_root_source(params)
        source = params[:source]
        source = params[:source] while source.params[:source]
      end
    end
  end
end
