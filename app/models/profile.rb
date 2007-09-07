# A Profile is the representation and web-presence of an individual or an
# organization. Every Profile is attached to its VirtualCommunity of origin,
# which by default is the one returned by VirtualCommunity:default.
class Profile < ActiveRecord::Base

  after_create do |profile|
    homepage = Article.new
    homepage.title = profile.name
    homepage.parent = Comatose::Page.root
    homepage.slug = profile.identifier
    homepage.save!
  end

  after_destroy do |profile|
    Article.find_by_path(profile.identifier).destroy
  end

  # Valid identifiers must match this format.
  IDENTIFIER_FORMAT = /^[a-z][a-z0-9_]*[a-z0-9]$/

  # These names cannot be used as identifiers for Profiles
  RESERVED_IDENTIFIERS = %w[
  admin
  system
  myprofile
  profile
  cms
  community
  test
  ]

  acts_as_taggable

  has_many :domains, :as => :owner
  belongs_to :virtual_community
  has_many :affiliations, :dependent => :destroy
  has_many :people, :through => :affiliations


  # Sets the identifier for this profile. Raises an exception when called on a
  # existing profile (since profiles cannot be renamed)
  def identifier=(value)
    unless self.new_record?
      raise ArgumentError.new(_('An existing profile cannot be renamed.'))
    end
    self[:identifier] = value
  end

  validates_presence_of :identifier, :name
  validates_format_of :identifier, :with => IDENTIFIER_FORMAT
  validates_exclusion_of :identifier, :in => RESERVED_IDENTIFIERS

  # A profile_owner cannot have more than one profile, but many profiles can exist
  # without being associated to a particular user.
  validates_uniqueness_of :user_id, :allow_nil =>true

  # creates a new Profile. By default, it is attached to the default
  # VirtualCommunity (see VirtualCommunity#default), unless you tell it
  # otherwise
  def initialize(*args)
    super(*args)
    self.virtual_community ||= VirtualCommunity.default
  end

  # Searches tags by tag or name
  def self.search(term)
    find_tagged_with(term) + find_all_by_name(term)
  end

  def homepage(reload = false)
    @homepage = nil if reload
    @homepage ||= Article.find_by_path(self.identifier)
  end

  # Returns information about the profile's owner that was made public by
  # him/her. The returned value must be an array in the followinf format:
  #
  #   [
  #     [ 'First Field', first_field_value ],
  #     [ 'Second Field', second_field_value ],
  #   ]
  #
  # This information shall be used by user interface to present the information
  #
  # In this class, this method returns nil, what is interpreted as "no
  # information at all". Subclasses must override this method to provide their
  # specific information.
  def info
    nil
  end

end
