require_relative '../nested_helper/environment'

module ElasticsearchIndexedModel

  def self.included base
    base.send :include, Elasticsearch::Model
    base.send :include, Elasticsearch::Model::Callbacks

    base.send :index_name, "#{Rails.env}_#{base.index_name}"

    base.extend ClassMethods
    base.send :include, InstanceMethods

    base.class_eval do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          base.indexed_fields.each do |field, value|
            type = value[:type].presence

            if type == :nested
              indexes(field, type: type) do
                value[:hash].each do |hash_field, hash_value|
                  indexes(hash_field, base.indexes_as_hash(hash_field,hash_value[:type].presence))
                end
              end
            else
               indexes(field, base.indexes_as_hash(field,type))
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

    def indexes_as_hash(name, type)
      hash = {}
      if type.nil?
        hash[:fields] = raw_field(name, type)
      else
        hash[:type] = type if not type.nil?
      end
      hash
    end

    def raw_field name, type
      {
        raw: {
          type: "string",
          index: "not_analyzed"
        }
      }
    end

    def indexed_fields
      fields = {
                :environment  => {type: :nested, hash: NestedEnvironment::environment_hash },
                :category_ids => {type: :integer },
                :created_at   => {type: :date }
      }
      fields.update(self::SEARCHABLE_FIELDS)
      fields.update(self.control_fields)
      fields
    end

  end

  module InstanceMethods
    def as_indexed_json options={}
        attrs = {}

        self.class.indexed_fields.each do |field, value|
          type = value[:type].presence

          if type == :nested
            attrs[field] = {}
            value[:hash].each do |hash_field, hash_value|
              attrs[field][hash_field] = self.send(field).send(hash_field)
            end
          else
            attrs[field] = self.send(field)
          end
        end
        attrs.as_json
    end
  end

end
