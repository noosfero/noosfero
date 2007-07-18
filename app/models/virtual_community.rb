class VirtualCommunity < ActiveRecord::Base

  # returns the available features for a VirtualCommunity, in the form of a
  # hash, with pairs in the form <tt>'feature_name' => 'Feature name'</tt>.
  def self.available_features
    {
      'some_feature' => _('Some feature'),
      'other_feature' => _('Other feature'),
    }
  end
  
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

  # enables the features identified by <tt>features</tt>, which is expected to
  # be an Enumarable object containing the identifiers of the desired features.
  # Passing <tt>nil</tt> is the same as passing an empty Array.
  def enabled_features=(features)
    features ||= []
    self.class.available_features.keys.each do |feature|
      if features.include? feature
        self.enable(feature)
      else
        self.disable(feature)
      end
    end
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
