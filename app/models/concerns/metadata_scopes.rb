module MetadataScopes
  extend ActiveSupport::Concern

  included do
    scope :with_metadata, -> metadata {
      where metadata.map{ |k, v| "metadata->>'#{k}' = '#{v}'"}.join(' AND ')
    }

    scope :has_metadata, -> key {
      where "metadata ? '#{key}'"
    }
  end
end
