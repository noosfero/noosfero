class VirtualCommunity < ActiveRecord::Base

  # TODO: these are test features
  EXISTING_FEATURES = {
    'feature1' => _('Feature 1'),
    'feature2' => _('Feature 2'),
    'feature3' => _('Feature 3'),
  }
  
  # #################################################
  # Relationships and applied behaviour
  # #################################################

  # One VirtualCommunity can be reached by many domains
  has_many :domains, :as => :owner

  # a VirtualCommunity can be configured
  acts_as_configurable

  # #################################################
  # Attributes
  # #################################################
  
  # Enables a feature
  def enable(feature)
    self.settings["#{feature}_enabled"] = true
  end

  # Disables a feature
  def disable(feature)
    self.settings["#{feature}_enabled"] = false
  end

  # Tells if a feature is enabled
  def enabled?(feature)
    self.settings["#{feature}_enabled"] == true
  end
  
  # #################################################
  # Validations
  # #################################################

  # <tt>name</tt> is mandatory
  validates_presence_of :name

  # only one virtual community can be the default one
  validates_uniqueness_of :is_default, :if => (lambda do |virtual_community| virtual_community.is_default? end), :message => _('Only one Virtual Community can be the default one')

  # #################################################
  # Business logic in general
  # #################################################

  # the default VirtualCommunity.
  def self.default
    self.find(:first, :conditions => [ 'is_default = ?', true ] )
  end

end
