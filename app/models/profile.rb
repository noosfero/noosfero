# A Profile is the representation and web-presence of an individual or an
# organization. Every Profile is attached to its VirtualCommunity of origin,
# which by default is the one returned by VirtualCommunity:default.
class Profile < ActiveRecord::Base

  # These names cannot be used as identifiers for Profiles
  RESERVED_IDENTIFIERS = %w[
  admin
  customize
  cms
  system
  community
  ]

  has_many :domains, :as => :owner
  belongs_to :virtual_community

  validates_presence_of :identifier
  validates_format_of :identifier, :with => /^[a-z][a-z0-9_]+[a-z0-9]$/
  validates_exclusion_of :identifier, :in => RESERVED_IDENTIFIERS

  # creates a new Profile. By default, it is attached to the default
  # VirtualCommunity (see VirtualCommunity#default), unless you tell it
  # otherwise
  def initialize(*args)
    super(*args)
    self.virtual_community ||= VirtualCommunity.default
  end

end
