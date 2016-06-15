require_relative '../../helpers/elasticsearch_helper'


class ElasticsearchPlugin::API < Grape::API
  include Api::Helpers

  resource :search do
    get do
      present target, :with => Api::Entities::Person
    end

    get 'types' do
      types = {types: ElasticsearchHelper::SEARCHABLE_TYPES.stringify_keys.keys}
      present types, with: Grape::Presenters::Presenter
    end

  end

end
