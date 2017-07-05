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
end
