class Role < ActiveRecord::Base

  has_many :role_assignments
  serialize :permissions, Array
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :key, :if => lambda { |role| !role.key.blank? }

  def initialize(*args)
    super(*args)
    self[:permissions] ||= []
  end

  def has_permission?(perm)
    permissions.include?(perm)
  end

  def has_kind?(k)
    permissions.any?{|p| perms[k].keys.include?(p)}
  end

  def kind
    perms.keys.detect{|k| perms[k].keys.include?(permissions[0]) }
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
end
