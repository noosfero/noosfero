class BscPlugin::Bsc < Enterprise

  has_many :enterprises
  has_many :enterprise_requests, :class_name => 'BscPlugin::AssociateEnterprise'

  validates_presence_of :nickname
  validates_presence_of :company_name
  validates_presence_of :cnpj
  validates_uniqueness_of :nickname
  validates_uniqueness_of :company_name
  validates_uniqueness_of :cnpj

  before_validation do |bsc|
    bsc.name = bsc.business_name || 'Sample name'
  end

  def already_requested?(enterprise)
    enterprise_requests.pending.map(&:enterprise).include?(enterprise)
  end

  def enterprises_to_json
    enterprises.map { |enterprise| {:id => enterprise.id, :name => enterprise.name} }.to_json
  end

  def control_panel_settings_button
    {:title => _('Bsc info and settings'), :icon => 'edit-profile-enterprise'}
  end

  def products(reload_flag=false)
    reload if reload_flag
    enterprises.map { |enterprise| enterprise.products }.flatten
  end

  def create_product?
    false
  end

  def self.identification
    'Bsc'
  end

end
