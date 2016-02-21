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
    roles = Array(roles)
    actual_roles = RoleAssignment.where(role_attributes nil, resource).map(&:role)

    (roles - actual_roles).each {|r| add_role(r, resource) }
    (actual_roles - roles).each {|r| remove_role(r, resource)}
  end

  def add_role(role, resource, attributes = {})
    attributes = role_attributes(role, resource).merge attributes
    if RoleAssignment.find_by(attributes).nil?
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
    roles_destroy = RoleAssignment.where(role_attributes role, resource)
    return if roles_destroy.empty?
    roles_destroy.map(&:destroy).all?
  end

  def find_roles(res)
    RoleAssignment.where(role_attributes nil, res)
  end

  def member_relation_of(profile)
    raise TypeError, "Expected instance of 'Profile' class, but '#{profile.class.name}' was founded" unless profile.is_a? Profile

    role_assignments.where(resource_id: profile.id)
  end

  def member_since_date(profile)
    result = member_relation_of(profile).to_a
    unless result.empty?
      result.last.created_at ? result.last.created_at.to_date : Date.yesterday
    end
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
