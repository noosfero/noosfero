class Role < ActiveRecord::Base

  PERMISSIONS = {
    :profile => {
      'edit_profile' => N_('Edit profile'),
      'post_content' => N_('Post content'),
      'destroy_profile' => N_('Destroy profile'),
    },
    :system => {
    }
  }

  def self.permission_name(p)
    msgid = PERMISSIONS.values.inject({}){|s,v| s.merge(v)}[p]
    gettext(msgid)
  end
  
  has_many :role_assignments

  serialize :permissions, Array
  
  def initialize(*args)
    super(*args)
    permissions = []
  end
  
  def has_permission?(perm)
    permissions.include?(perm)
  end
end
