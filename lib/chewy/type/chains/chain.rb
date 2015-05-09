module Chewy
  class Type
    module Chains
      class Chain
        attr_reader :path
        delegate :adapter, to: :@type

        def initialize type, path
          @type, @path = type, path.map(&:to_sym)
        end

        def target
          return @target if defined?(@target)
          @target = adapter.chain_target(adapter.target, path)
        end

        def chain name
          chain = self.class.new @type, @path + [name]
          chain if chain.target
        end

        def column *names
          column = Column.new self, names
          column if column.exists?
        end
        alias_method :columns, :column

        def method_missing method, *_, &block
          chain(method) || column(method) || super
        end

        def respond_to_missing? method, *_
          chain(method).present? || column(method).present? || super
        end
      end
    end
  end
end
