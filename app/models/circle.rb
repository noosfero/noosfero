class Circle < ApplicationRecord
  SEARCHABLE_FIELDS = {
    :name => {:label => _('Name'), :weight => 1}
  }

  _('Circle')

  has_many :profile_followers
  belongs_to :person, touch: true

  attr_accessible :name, :person, :profile_type

  validates :name, presence: true
  validates :person_id, presence: true
  validates :profile_type, presence: true
  validates :person_id, :uniqueness => {:scope => :name, :message => "can't add two circles with the same name"}

  validate :profile_type_must_be_in_list

  scope :by_owner, -> person{
    where(:person => person)
  }

  scope :with_name, -> name{
    where(:name => name)
  }

  def self.profile_types
    {
      _("Person") => Person.name,
      _("Community") => Community.name,
      _("Enterprise") => Enterprise.name
    }
  end

  def profile_type_must_be_in_list
    valid_profile_types = Circle.profile_types.values
    unless self.profile_type.in? valid_profile_types
      self.errors.add(:profile_type, "invalid profile type")
    end
  end

end
