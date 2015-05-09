require 'spec_helper'

describe Chewy::Type::Chains do
  let(:city) { PlacesIndex::City }
  let(:country) { PlacesIndex::Country }

  before do
    stub_model(:country)
    stub_model(:city)

    City.belongs_to :country
    Country.has_many :cities
  end

  before do
    stub_index(:places) do
      define_type City do
        field :name, :rating
      end

      define_type Country do
        field :name, :rating
      end
    end
  end

  describe '.chain' do
    specify { expect(city.chain(:name)).to be_nil }
    specify { expect(city.chain(:country, :name)).to be_nil }
    specify { expect(city.chain(:country)).to be_a Chewy::Type::Chains::Chain }
    specify { expect(city.chain(:country).path).to eq([:country]) }

    specify { expect(country.chain(:city)).to be_nil }
    specify { expect(country.chain(:cities)).to be_a Chewy::Type::Chains::Chain }
    specify { expect(country.chain(:cities).path).to eq([:cities]) }
  end

  describe '.chains_hash' do
    specify { expect(city.chains_hash).to eq({}) }

    context do
      before do
        stub_index(:places) do
          define_type City do
            # {city: {country_name: 'one', country: {name: 'one'}}}
            field :name, :rating
            field :country_name, value: country.name
            field :country do
              field :name, value: country.name
            end
          end

          define_type Country do
            # {
            #   country: {city_names: ['one', 'two'],
            #   cities: [{name: 'one'}, {name: 'two'}]}
            #   cities_ratings: [{rating: 1}, {rating: 2}]}
            # }
            field :name, :rating
            field :city_names, value: cities.name
            field :cities do
              field :name, value: cities.name
            end
            field :cities_ratings do
              field :rating, value: cities.rating
            end
          end
        end
      end

      specify { expect(city.chains_hash).to match({
        [:city, :country_name] => an_instance_of(Chewy::Type::Chains::Column)
          .and(have_attributes(chain: have_attributes(path: [:country]), columns: [:name])),
        [:city, :country, :name] => an_instance_of(Chewy::Type::Chains::Column)
          .and(have_attributes(chain: have_attributes(path: [:country]), columns: [:name]))
      }) }
      specify { expect(country.chains_hash).to match({
        [:country, :city_names] => an_instance_of(Chewy::Type::Chains::Column)
          .and(have_attributes(chain: have_attributes(path: [:cities]), columns: [:name])),
        [:country, :cities, :name] => an_instance_of(Chewy::Type::Chains::Column)
          .and(have_attributes(chain: have_attributes(path: [:cities]), columns: [:name])),
        [:country, :cities_ratings, :rating] => an_instance_of(Chewy::Type::Chains::Column)
          .and(have_attributes(chain: have_attributes(path: [:cities]), columns: [:rating]))
      }) }
    end
  end
end
