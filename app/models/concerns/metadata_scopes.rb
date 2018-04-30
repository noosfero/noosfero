module MetadataScopes
  extend ActiveSupport::Concern

  included do
    scope :with_metadata, -> metadata {
      where metadata.map{ |k, v| "metadata->>'#{k}' = '#{v}'"}.join(' AND ')
    }

    scope :with_plugin_metadata, -> plugin, metadata {
      plugin_namespace = "#{plugin.public_name}_plugin"
      where metadata.map{ |k, v| "metadata #> '{#{plugin_namespace},#{k}}' = '#{v.to_json}'"}.join(' AND ')
    }

    scope :has_metadata, -> key {
      where "metadata ? '#{key}'"
    }
  end

  class_methods do
    def metadata_items(*items)
      attr_accessible *items

      items.each do |item|
        define_method item do
          self.metadata[item.to_s]
        end

        define_method "#{item}=" do |value|
          self.metadata[item.to_s] = value
        end
      end
    end
  end
end
