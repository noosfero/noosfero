class Role < ActiveRecord::Base

  PERMISSIONS = {
    :profile => {
      'edit_profile' => N_('Edit profile'),
      'destroy_profile' => N_('Destroy profile'),
      'manage_memberships' => N_('Manage memberships'),
      'post_content' => N_('Post content'),
    },
    :system => {
    }
  }

  PERMISSIONS_LIST = PERMISSIONS.values.map{|h| h.keys }.flatten

  def self.permission_name(p)
    msgid = PERMISSIONS.values.inject({}){|s,v| s.merge(v)}[p]
    gettext(msgid)
  end

  has_many :role_assignments
  serialize :permissions, Array
  validates_uniqueness_of :name

  def validate
    unless (permissions - PERMISSIONS_LIST).empty?
      errors.add :permissons, 'non existent permission'
    end
  end
 
  def initialize(*args)
    super(*args)
    self[:permissions] ||= []
  end

  def has_permission?(perm)
    permissions.include?(perm)
  end

  def has_kind?(kind)
    permissions.any?{ |p| PERMISSIONS[kind][p] }
  end
end
