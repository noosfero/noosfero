require_dependency 'enterprise'

class Enterprise
  belongs_to :bsc, :class_name => 'BscPlugin::Bsc'
  FIELDS << 'bsc_id'
  FIELDS << 'enabled'
  FIELDS << 'validated'

  named_scope :validated, :conditions => {:validated => true}
  named_scope :not_validated, :conditions => {:validated => false}
end
