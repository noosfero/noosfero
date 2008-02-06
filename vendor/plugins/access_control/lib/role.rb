class Role < ActiveRecord::Base

  has_many :role_assignments
  serialize :permissions, Array
  validates_presence_of :name
  validates_uniqueness_of :name

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

  protected
  def perms
    ActiveRecord::Base::PERMISSIONS
  end
end
