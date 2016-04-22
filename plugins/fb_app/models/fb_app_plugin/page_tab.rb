class FbAppPlugin::PageTab < ApplicationRecord

  # FIXME: rename table to match model
  self.table_name = :fb_app_plugin_page_tab_configs

  attr_accessible :owner_profile, :profile_id, :page_id,
    :config_type, :profile_ids, :query,
    :title, :subtitle

  belongs_to :owner_profile, foreign_key: :profile_id, class_name: 'Profile'

  acts_as_having_settings field: :config

  ConfigTypes = [:profile, :profiles, :query]
  EnterpriseConfigTypes = [:own_profile] + ConfigTypes

  validates_presence_of :page_id
  validates_uniqueness_of :page_id
  validates_inclusion_of :config_type, in: ConfigTypes + EnterpriseConfigTypes

  def self.page_ids_from_tabs_added tabs_added
    tabs_added.map{ |id, value| id }
  end

  def self.create_from_page_ids page_ids, attrs = {}
    attrs.delete :page_id
    page_ids.map do |page_id|
      page_tab = FbAppPlugin::PageTab.where(page_id: page_id).first
      page_tab ||= FbAppPlugin::PageTab.new page_id: page_id
      page_tab.update! attrs
      page_tab
    end
  end
  def self.create_from_tabs_added tabs_added, attrs = {}
    page_ids = self.page_ids_from_tabs_added tabs_added
    self.create_from_page_ids page_ids, attrs
  end

  def self.facebook_url page_id
    "https://facebook.com/#{page_id}?sk=app_#{FbAppPlugin.page_tab_app_credentials[:id]}"
  end

  def facebook_url
    self.class.facebook_url self.page_id
  end

  def types
    if self.owner_profile.present? and self.owner_profile.enterprise? then EnterpriseConfigTypes else ConfigTypes end
  end

  def config_type
    self.config[:type] || (self.owner_profile ? :own_profile : :profile)
  end
  def config_type= value
    self.config[:type] = value.to_sym
  end

  def value
    case self.config_type
    when :profiles
      self.profiles.map(&:identifier).join(' OR ')
    else
      self.send self.config_type
    end
  end
  def blank?
    self.value.blank? rescue true
  end

  def own_profile
    self.owner_profile
  end
  def profiles
    Profile.where(id: self.config[:profile_ids])
  end
  def profile
    self.profiles.first
  end
  def profile_ids
    self.profiles.map(&:id)
  end
  def query
    self.config[:query]
  end

  def title
    self.config[:title]
  end
  def title= value
    self.config[:title] = value
  end

  def subtitle
    self.config[:subtitle]
  end
  def subtitle= value
    self.config[:subtitle] = value
  end

  def profile_ids= ids
    ids = ids.to_s.split(',')
    self.config[:type] = if ids.size == 1 then :profile else :profiles end
    self.config[:profile_ids] = ids
  end

  def query= value
    self.config[:type] = :query
    self.config[:query] = value
  end

end
