require 'chewy/type/chains/stash'
require 'chewy/type/chains/chain'
require 'chewy/type/chains/column'

module Chewy
  class Type
    module Chains
      extend ActiveSupport::Concern

      module ClassMethods
        def chain *path
          chain = Chain.new self, path.flatten
          chain if chain.target
        end

        def chains_hash
          Hash[_fields.select { |field|
            field.value.is_a?(Chewy::Type::Chains::Column)
          }.map { |field| [field.path, field.value] }]
        end

        def method_missing method, *_, &block
          chain(method) || super
        end

        def respond_to_missing? method, *_
          chain(method).present? || super
        end
      end
    end
  end
end
