require_dependency 'enterprise'

class Enterprise
  belongs_to :bsc, :class_name => 'BscPlugin::Bsc'
  has_and_belongs_to_many :contracts, :class_name => 'BscPlugin::Contract', :join_table => 'bsc_plugin_contracts_enterprises'

  FIELDS << 'bsc_id'
  FIELDS << 'enabled'
  FIELDS << 'validated'

  scope :validated, -> { where validated: true }
  scope :not_validated, -> { where validated: false }
end
