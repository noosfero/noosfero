module ElasticsearchIndexedModel

  def self.included base
    base.send :include, Elasticsearch::Model
    base.send :include, Elasticsearch::Model::Callbacks

    base.send :index_name, "#{Rails.env}_#{base.index_name}"
    base.extend ClassMethods
    base.class_eval do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          base.indexed_fields.each do |field, value|
            value = {} if value.nil?
            type =  value[:type].presence
            if type.nil?
              indexes(field, fields: base.raw_field(field))
            else
              indexes field, type: type
            end
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
   base.send :import
  end

  module ClassMethods
    def raw_field name
      {
        raw: {
          type: "string",
          index: "not_analyzed"
        }
      }
    end

    def indexed_fields
      self::SEARCHABLE_FIELDS.merge self.control_fields
    end

  end

end
