require 'uri'

class CustomRoutesPlugin::Route < ApplicationRecord

  belongs_to :environment

  attr_accessible :environment_id, :source_url, :target_url, :enabled

  validates_presence_of :source_url, :target_url
  validates_uniqueness_of :source_url
  validate :urls_must_be_relative

  after_save :reload_routes
  after_rollback :reload_routes

  def urls_must_be_relative
    [:target_url, :source_url].each do |attr|
      begin
        url = URI.parse(self.send(attr))
        errors.add(attr, 'must be a relative URL') unless url.relative?
      rescue URI::InvalidURIError
        errors.add(attr, 'must be a valid URL')
      end
    end
  end

  def reload_routes
    unless CustomRoutesPlugin::CustomRoutes.reload
      errors.add(:target_url, 'must be valid within the server')
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

end
