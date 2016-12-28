class ProfileFollower < ApplicationRecord
  self.table_name = :profiles_circles
  track_actions :new_follower, :after_create, :keep_params => ["follower.name", "follower.url", "follower.profile_custom_icon"], :custom_user => :profile

  attr_accessible :profile, :circle

  belongs_to :profile, touch: true
  belongs_to :circle, touch: true

  has_one :person, through: :circle
  alias follower person

  validates_presence_of :profile_id, :circle_id
  validates :profile_id, :uniqueness => {:scope => :circle_id, :message => "can't put a profile in the same circle twice"}

  scope :with_follower, -> person{
    joins(:circle).where('circles.person_id = ?', person.id)
  }

  scope :with_profile, -> profile{
    where(:profile => profile)
  }

  scope :with_circle, -> circle{
    where(:circle => circle)
  }

end
