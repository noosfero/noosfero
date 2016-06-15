class ElasticsearchPlugin::API < Grape::API
  include Api::Helpers

  resource :search do
    get do
      target  = Person.first
      present target, :with => Api::Entities::Person
    end
  end
end
