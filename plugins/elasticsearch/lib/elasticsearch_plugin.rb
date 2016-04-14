class ElasticsearchPlugin < Noosfero::Plugin

  def self.plugin_name
    # FIXME
    "ElasticsearchPlugin"
  end

  def self.plugin_description
    # FIXME
    _("A plugin that does this and that.")
  end

  Noosfero::Application.class_eval do
    config.after_initialize do

      Rails.application.eager_load! #TODO: REMOVE THIS LINE

      models = ActiveRecord::Base.descendants.select do |model|
        model.const_defined?("SEARCHABLE_FIELDS")
      end

      models.each do |model|
        model.class_eval do
          include Elasticsearch::Model
          include Elasticsearch::Model::Callbacks

          settings index: { number_of_shards: 1 } do
            mappings dynamic: 'false' do
              model::SEARCHABLE_FIELDS.each do |field, value|
                indexes field
              end
            end
          model.__elasticsearch__.client.indices.delete \
            index: model.index_name rescue nil
          model.__elasticsearch__.client.indices.create \
            index: model.index_name,
            body: {
              settings: model.settings.to_hash,
              mappings: model.mappings.to_hash
            }

          model.import
          end
        end
      end
    end
  end
end
