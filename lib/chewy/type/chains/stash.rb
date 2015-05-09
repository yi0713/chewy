module Chewy
  class Type
    module Chains
      class Stash
        def initialize type, collection
          @type, @collection = type, collection
        end

        def fetch field_path, object
          data[field_path][object.id]
        end

      private

        def data
          @data ||= type.chains_hash.sort_by { |(_, chain)| chain.path }
            .group_by { |(_, chain)| chain.path }
            .inject({}) do |data, (chain_path, chains_hash)|
              results = type.adapter.columns_data collection, chain_path,
                chains_hash.map(&:second).map(&:columns).flatten.uniq

              chains_hash.each do |(field_path, chain)|
                data[field_path] = Hash[results.map do |result|
                  [result[:id], result.values_at(*chain.columns)]
                end]
              end
            end
        end
      end
    end
  end
end
