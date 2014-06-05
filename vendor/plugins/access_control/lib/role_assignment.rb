class RoleAssignment < ActiveRecord::Base

  attr_accessible :accessor_id, :accessor_type, :role_id, :resource_id, :resource_type

  belongs_to :role
  belongs_to :accessor, :polymorphic => true
  belongs_to :resource, :polymorphic => true

  validates_presence_of :role, :accessor
  
  track_actions :join_community, :after_create, :keep_params => ["resource.name", "resource.url", "resource.profile_custom_icon"], :if => Proc.new { |x| x.resource.is_a?(Community) && x.accessor.role_assignments.count(:conditions => { :resource_id => x.resource.id, :resource_type => 'Profile' }) == 1 }, :custom_user => :accessor, :custom_target => :resource
  
  track_actions :add_member_in_community, :after_create, :if => Proc.new { |x| x.resource.is_a?(Community) && x.accessor.role_assignments.count(:conditions => { :resource_id => x.resource.id, :resource_type => 'Profile' }) == 1 }, :custom_user => :accessor, :custom_target => :resource
  
  def has_permission?(perm, res)
    return false unless role.has_permission?(perm.to_s) && (resource || is_global)
    return true if is_global
    return false if res == 'global'
    while res
      return true if (resource == res)
      res = res.superior_instance
    end
    return (resource == res)
  end
end
