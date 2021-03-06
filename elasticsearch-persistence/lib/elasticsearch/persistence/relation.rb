module Elasticsearch
  module Persistence
    class Relation

        MULTI_VALUE_METHODS  = [:order, :where, :bind, :extending, :unscope]
        SINGLE_VALUE_METHODS = [:limit, :offset, :routing, :size]

        INVALID_METHODS_FOR_DELETE_ALL = [:limit, :offset]

        VALUE_METHODS = MULTI_VALUE_METHODS + SINGLE_VALUE_METHODS

        include FinderMethods, SpawnMethods, QueryMethods, SearchOptionMethods, Delegation

        attr_reader :klass, :loaded
        alias :model :klass
        alias :loaded? :loaded


        def initialize(klass, values={})
            @klass  = klass
            @values = values
            @offsets = {}
            @loaded = false
        end

        def to_a
          load
          @records
        end
        alias :results :to_a

        def as_json(options = nil)
          to_a.as_json(options)
        end

        def to_elastic
          query_builder.to_elastic
        end

        def empty?
        end

        def any?
        end

        def many?
        end

        def create(*args, &block)
          scoping { @klass.create!(*args, &block) }
        end

        def scoping
          previous, klass.current_scope = klass.current_scope, self
          yield
        ensure
          klass.current_scope = previous
        end

        def blank?
        end

        def load
          exec_queries unless loaded?

          self
        end
        alias :fetch :load

        def exec_queries
          @records = @klass.fetch_results(query_builder)

          @loaded = true
          @records
        end

        def values
          Hash[@values]
        end

        def inspect
          entries = to_a.results.take([size_value.to_i + 1, 11].compact.min).map!(&:inspect)
          "#<#{self.class.name} [#{entries.join(', ')}, total: #{to_a.total}, max: #{to_a.total} ]>"
        end


        private

        def query_builder
          QueryBuilder.new(values)
        end

    end
  end
end
