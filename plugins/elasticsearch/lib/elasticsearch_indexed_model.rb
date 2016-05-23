module ElasticsearchIndexedModel

  def self.included base
    base.send :include, Elasticsearch::Model
    base.class_eval do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          base::SEARCHABLE_FIELDS.each do |field, value|
            indexes field
            print '.'
          end
        end
        base.__elasticsearch__.client.indices.delete \
          index: base.index_name rescue nil
        base.__elasticsearch__.client.indices.create \
          index: base.index_name,
          body: {
            settings: base.settings.to_hash,
            mappings: base.mappings.to_hash
          }
      end
    end
    base.extend ClassMethods
    base.send :import
  end

  module ClassMethods
    def indexable_fields
      self::SEARCHABLE_FIELDS.keys + self.control_fields
    end
  end

end
