class SuppliersPlugin::Consumer < SuppliersPlugin::Supplier

  self.table_name = :suppliers_plugin_suppliers

  belongs_to :profile, foreign_key: :consumer_id, optional: true
  belongs_to :supplier, foreign_key: :profile_id, optional: true
  alias_method :consumer, :profile

  def name
    self.profile.name
  end

end
