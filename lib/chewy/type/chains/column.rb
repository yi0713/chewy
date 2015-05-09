module Chewy
  class Type
    module Chains
      class Column
        attr_reader :columns, :chain
        delegate :adapter, to: :@chain

        def initialize chain, columns, methods = []
          @chain, @columns, @methods = chain, Array.wrap(columns).flatten.map(&:to_sym), methods
        end

        def exists?
          return @exists if defined?(@exists)
          @exists = @chain.target ? adapter.columns_exists?(@chain.target, @columns) : false
        end

        def evaluate values
          methods.inject(values) do |memo, (method, arguments, block)|
            memo.send(method, *arguments, &block)
          end
        end

        def method_missing method, *arguments, &block
          self.class.new @chain, @columns, @methods + [[method, arguments, block]]
        end
      end
    end
  end
end
