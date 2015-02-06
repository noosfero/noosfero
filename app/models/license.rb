class License < ActiveRecord::Base

  attr_accessible :name, :url

  SEARCHABLE_FIELDS = {
    :name => {:label => _('Name'), :weight => 10},
    :url => {:label => _('URL'), :weight => 5},
  }

  belongs_to :environment
  has_many :content, :class_name => 'Article', :foreign_key => 'license_id'

  validates_presence_of :name, :environment
  validates_presence_of :slug, :if => lambda {|license| license.name.present?}
  validates_uniqueness_of :slug, :scope => :environment_id

  attr_accessible :environment, :slug

  before_validation do |license|
    license.slug ||= license.name.to_slug if license.name.present?
  end
end
