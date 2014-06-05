module ActsAsAccessor

  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_accessor
      has_many :role_assignments, :as => :accessor, :dependent => :destroy
    end
  end

  def has_permission?(permission, resource = nil)
    return true if resource == self
    role_assignments.includes([:resource,:role]).any? {|ra| ra.has_permission?(permission, resource)}
  end

  def define_roles(roles, resource)
    roles = [roles] unless roles.kind_of?(Array)
    actual_roles = RoleAssignment.find( :all, :conditions => role_attributes(nil, resource) ).map(&:role)

    (roles - actual_roles).each {|r| add_role(r, resource) }
    (actual_roles - roles).each {|r| remove_role(r, resource)}
  end

  def add_role(role, resource)
    attributes = role_attributes(role, resource)
    if RoleAssignment.find(:all, :conditions => attributes).empty?
      ra = RoleAssignment.new(attributes)
      role_assignments << ra
      resource.role_assignments << ra
      ra.save
    else
      false
    end
  end

  def remove_role(role, resource)
    return unless role
    roles_destroy = RoleAssignment.find(:all, :conditions => role_attributes(role, resource))
    return if roles_destroy.empty?
    roles_destroy.map(&:destroy).all?
  end

  def find_roles(res)
    RoleAssignment.find(:all, :conditions => role_attributes(nil, res))
  end

  protected
  def role_attributes(role, resource)
    attributes = {:accessor_id => self.id, :accessor_type => self.class.base_class.name}
    if role
      attributes[:role_id] = role.id
    end
    if resource == 'global'
      attributes[:is_global] = true
      resource = nil
    end
    if resource
      attributes[:resource_id]   = resource.id 
      attributes[:resource_type] = resource.class.base_class.name
    else
      attributes[:resource_id]   = nil 
      attributes[:resource_type] = nil
    end
    attributes
  end
end

ActiveRecord::Base.send(:include, ActsAsAccessor)
