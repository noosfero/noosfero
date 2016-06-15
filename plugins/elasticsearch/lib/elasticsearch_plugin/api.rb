require_relative '../../helpers/elasticsearch_helper'
require_relative 'entities'

class ElasticsearchPlugin::API < Grape::API
  include Api::Helpers
  helpers ElasticsearchHelper

  resource :search do
    get do
      target = process_results
      present target,
              :with => Elasticsearch::Entities::Result,
              :types => ElasticsearchHelper.searchable_types.except(:all).keys.map { |key| key.to_s.classify }
    end

    get 'types' do
      types = {types: ElasticsearchHelper::searchable_types.stringify_keys.keys}
      present types, with: Grape::Presenters::Presenter
    end

  end

end
