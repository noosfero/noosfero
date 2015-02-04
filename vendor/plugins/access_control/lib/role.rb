class Role < ActiveRecord::Base

  attr_accessible :key, :name, :environment, :permissions

  has_many :role_assignments, :dependent => :destroy
  belongs_to :environment
  serialize :permissions, Array
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :environment_id
  validates_uniqueness_of :key, :if => lambda { |role| !role.key.blank? }, :scope => :environment_id
  before_validation :create_key, :on => :create

  def initialize(*args)
    super(*args)
  end

  def key=(value)
    if self[:key] && system
      raise ArgumentError, 'Can\'t change key of system role'
    else
      self[:key] = value
    end
  end

  def permissions
    self[:permissions] ||= []
  end

  def has_permission?(perm)
    permissions.include?(perm)
  end

  def has_kind?(k)
    perms[k] && permissions.any?{|p| perms[k].keys.include?(p)}
  end

  def kind
    key.present? && key.starts_with?('environment_') ? 'Environment' : 'Profile'
  end

  def name
    text = self[:name]
    self.class.included_modules.map(&:to_s).include?('GetText') ? gettext(text) : text
  end

  before_destroy :check_for_system_defined_role
  def check_for_system_defined_role
    ! self.system
  end

  protected
  def perms
    ActiveRecord::Base::PERMISSIONS
  end

  private
  def create_key
    self.key = 'profile_' + self.name.gsub(' ', '_').gsub(/[^a-zA-Z0-9_]/, '').downcase if self.key.blank? && !self.name.blank?
  end
end
