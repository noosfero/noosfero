Noosfero::Application.class_eval do

  config.after_initialize do
    Rails.application.eager_load! #TODO: REMOVE THIS LINE
    indeces_models searchables_models
  end

  def searchables_models
    ActiveRecord::Base.descendants.select do |model|
        model.const_defined?("SEARCHABLE_FIELDS")
    end
  end

  def indeces_models models
    indexed_models = Array.new
    models.each do |model|
        next if indexed_models.include? model

        create_searchable_model model
        indexed_models.push model

        if model.descendants.count > 0
            model.descendants.each { | descendant_model| 
                indexed_models.push descendant_model
                create_searchable_model descendant_model
            }
        end

    end

  end

  def create_searchable_model model
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
