module MetadataScopes
  extend ActiveSupport::Concern

  included do
    scope :with_metadata, -> metadata {
      term = metadata.map { |key, value| "#{key}=>#{value}"}.join(',')
      where("metadata @> '#{term}'")
    }

    scope :has_metadata, -> key {
      where("metadata ? '#{key}'")
    }
  end
end
