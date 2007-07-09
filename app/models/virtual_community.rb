class VirtualCommunity < ActiveRecord::Base

  # One VirtualCommunity can be reached by many domains
  has_many :domains, :as => :owner

  # a VirtualCommunity can be configured
  acts_as_configurable

  # <tt>name</tt> is mandatory
  validates_presence_of :name

  # only one virtual community can be the default one
  validates_uniqueness_of :is_default, :if => (lambda do |virtual_community| virtual_community.is_default? end), :message => _('Only one Virtual Community can be the default one')

  # VirtualCommunity configuration
  serialize :configuration, Hash

  # a Hash with configuration parameters for this community. The configuration
  # contains general parameters of the VirtualCommunity as well as
  # enabling/disabling optional features.
  def configuration
    self[:configuration] ||= Hash.new
  end

  # the default VirtualCommunity.
  def self.default
    self.find(:first, :conditions => [ 'is_default = ?', true ] )
  end

end
