require 'uri'

class CustomRoutesPlugin::Route < ApplicationRecord

  belongs_to :environment

  attr_accessible :environment_id, :source_url, :target_url, :enabled

  include MetadataScopes
  store_accessor :metadata

  validates_presence_of :source_url, :target_url
  validates_uniqueness_of :source_url
  validate :urls_must_be_relative

  before_save :set_route_hash
  after_save :reload_routes
  after_destroy :reload_routes
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

  def set_route_hash
    begin
      self.metadata = Rails.application.routes.recognize_path(target_url)
    rescue ActionController::RoutingError => e
      # Pretty much any URL will be valid because of the view_page, but still
      errors.add(:target_url, 'must be valid within the server')
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def reload_routes
    CustomRoutesPlugin::CustomRoutes.reload
  end

end
