class RoleAssignment < ActiveRecord::Base
  belongs_to :role
  belongs_to :person
  belongs_to :resource, :polymorphic => true

  def has_permission?(perm, res)
    role.has_permission?(perm.to_s) && (resource == res)
  end
end
