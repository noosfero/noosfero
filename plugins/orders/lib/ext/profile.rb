require_dependency 'profile'
require_dependency 'community'

([Profile] + Profile.descendants).each do |subclass|
subclass.class_eval do

  # cannot use :order because of months/years named_scope
  has_many :orders, class_name: 'OrdersPlugin::Sale', foreign_key: :profile_id
  has_many :sales, class_name: 'OrdersPlugin::Sale', foreign_key: :profile_id
  has_many :purchases, class_name: 'OrdersPlugin::Purchase', foreign_key: :consumer_id

  has_many :ordered_items, -> { order 'name ASC' }, through: :orders, source: :items

  has_many :sales_consumers, through: :sales, source: :consumer
  has_many :purchases_consumers, through: :sales, source: :consumer

  has_many :sales_profiles, through: :sales, source: :profile
  has_many :purchases_profiles, through: :sales, source: :profile

end
end

class Profile

  # FIXME move to core
  def has_admin? person
    return unless person
    person.has_permission? 'edit_profile', self
  end

  def sales_all_consumers
    consumers = self.sales_consumers.order 'name ASC'
    consumers.concat self.suppliers.except_self.order('name ASC') if self.respond_to? :suppliers
    consumers.uniq
  end
  def purchases_all_consumers
    consumers = self.purchases_consumers.order 'name ASC'
    consumers.concat self.consumers.except_self.order('name ASC') if self.respond_to? :consumers
    consumers.uniq
  end

  def self.create_orders_manager_role env_id
    env = Environment.find env_id
    Role.create! environment: env,
      key: "profile_orders_manager",
      name: I18n.t("orders_plugin.lib.ext.profile.orders_manager"),
      permissions: [
        'manage_orders',
      ]
  end

  def orders_managers
    self.members_by_role Profile::Roles.orders_manager(environment.id)
  end

  PERMISSIONS['Profile']['manage_orders'] = N_('Manage orders')
  module Roles
    def self.orders_manager env_id
      role = find_role 'orders_manager', env_id
      role ||= Profile.create_orders_manager_role env_id
      role
    end

    class << self
      def all_roles_with_orders_manager env_id
        roles = all_roles_without_orders_manager env_id
        if not roles.find{ |r| r.key == 'profile_orders_manager' }
          Profile.create_orders_manager_role env_id
          roles = all_roles_without_orders_manager env_id
        end

        roles
      end
      alias all_roles_without_orders_manager all_roles
      alias all_roles all_roles_with_orders_manager
    end
  end

end
