class RoleAssignment < ActiveRecord::Base
  belongs_to :role
  belongs_to :accessor, :polymorphic => true
  belongs_to :resource, :polymorphic => true

  validates_presence_of :role, :accessor
  
  track_actions :join_community, :after_create, :keep_params => ["resource.name", "resource.url", "resource.profile_custom_icon"], :if => Proc.new { |x| x.resource.is_a?(Community) && x.accessor.role_assignments.count(:conditions => { :resource_id => x.resource.id, :resource_type => 'Profile' }) == 1 }
  
  track_actions :leave_community, :before_destroy, :keep_params => ["resource.name", "resource.url", "resource.profile_custom_icon"], :if => Proc.new { |x| x.resource.is_a?(Community) && x.accessor.role_assignments.count(:conditions => { :resource_id => x.resource.id, :resource_type => 'Profile' }) == 1 }
  
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
