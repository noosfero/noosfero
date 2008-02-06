class RoleAssignment < ActiveRecord::Base
  belongs_to :role
  belongs_to :accessor, :polymorphic => true
  belongs_to :resource, :polymorphic => true

  validates_presence_of :role, :accessor

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
