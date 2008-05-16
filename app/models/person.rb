# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile

  acts_as_accessor

  has_many :friendships
  has_many :friends, :class_name => 'Person', :through => :friendships

  def suggested_friend_groups
    (friend_groups + [ _('friends'), _('work'), _('school'), _('family') ]).map {|i| i if !i.empty?}.compact.uniq
  end

  def friend_groups
    friendships.map { |item| item.group }.uniq
  end

  def add_friend(friend, group = nil)
    self.friendships.build(:friend => friend, :group => group).save!
  end

  def remove_friend(friend)
    friends.delete(friend)
  end

  settings_items :photo, :contact_information, :birth_date, :sex, :city, :state, :country

  def summary
    ['name', 'contact_information', 'contact_phone', 'sex', 'birth_date', 'address', 'city', 'state', 'country'].map do |col|
      [ col.humanize, self.send(col) ]
    end
  end

  def self.conditions_for_profiles(conditions, person)
    new_conditions = sanitize_sql(['role_assignments.accessor_id = ?', person])
    new_conditions << ' AND ' +  sanitize_sql(conditions) unless conditions.blank?
    new_conditions
  end

  def memberships(conditions = {})
    Profile.find(
      :all, 
      :conditions => self.class.conditions_for_profiles(conditions, self), 
      :joins => "LEFT JOIN role_assignments ON profiles.id = role_assignments.resource_id AND role_assignments.resource_type = \'#{Profile.base_class.name}\'",
      :select => 'profiles.*').uniq
  end

  def enterprise_memberships
    memberships(:type => Enterprise.name)
  end

  alias :enterprises :enterprise_memberships

  def community_memberships
    memberships(:type => Community.name)
  end

  alias :communities :community_memberships

  validates_presence_of :user_id
  validates_uniqueness_of :user_id

  def email
    self.user.nil? ? nil : self.user.email
  end

  def is_admin?
    role_assignments.map{|ra|ra.role.permissions}.any? do |ps|
      ps.any? do |p|
        ActiveRecord::Base::PERMISSIONS[:environment].keys.include?(p)
      end
    end
  end

  # FIXME this is *weird*, because this class is not inheriting the callback
  # from Profile !!! 
  hacked_after_create :create_default_set_of_boxes_for_person
  def create_default_set_of_boxes_for_person
    3.times do
      self.boxes << Box.new
    end

    # main area
    self.boxes.first.blocks << MainBlock.new

    # "left" area
    self.boxes[1].blocks << ProfileInfoBlock.new
    self.boxes[1].blocks << RecentDocumentsBlock.new

    # right area
    self.boxes[2].blocks << TagsBlock.new
    self.boxes[2].blocks << FriendsBlock.new
    self.boxes[2].blocks << CommunitiesBlock.new
    self.boxes[2].blocks << EnterprisesBlock.new
      
    true
  end

  # FIXME this is *weird*, because this class is not inheriting the callbacks
  before_create :set_default_environment
  hacked_after_create :insert_default_homepage_and_feed

  def name
    if !self[:name].nil?
      self[:name]
    else
      self.user ? self.user.login : nil
    end
  end

  has_and_belongs_to_many :favorite_enterprises, :class_name => 'Enterprise', :join_table => 'favorite_enteprises_people'

end
