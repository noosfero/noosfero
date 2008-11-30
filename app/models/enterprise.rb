# An enterprise is a kind of organization. According to the system concept,
# only enterprises can offer products and services.
class Enterprise < Organization

  N_('Enterprise')

  has_many :products, :dependent => :destroy

  extra_data_for_index :product_categories

  def product_categories
    products.map{|p| p.category_full_name}.compact
  end

  def product_updated
    ferret_update
  end

  after_save do |e|
    e.products.each{ |p| p.enterprise_updated(e) }
  end

  def closed?
    true
  end

  def blocked?
    data[:blocked]
  end

  def block
    data[:blocked] = true
    save
  end

  def enable(owner)
    return if enabled
    affiliate(owner, Profile::Roles.all_roles)
    update_attribute(:enabled,true)
    save
  end

  def question
    if !self.foundation_year.blank?
      :foundation_year
    elsif !self.cnpj.blank?
      :cnpj
    else
      nil
    end
  end

  after_create :create_activation_task
  def create_activation_task
    if !self.enabled
      EnterpriseActivation.create!(:enterprise => self, :code_length => 7)
    end
  end

  def default_set_of_blocks
    blocks = [
      [MainBlock],
      [ProfileInfoBlock, MembersBlock],
      [RecentDocumentsBlock]
    ]
    if !environment.enabled?('disable_products_for_enterprises')
      blocks[2].unshift ProductsBlock
    end
    blocks
  end

  def template
    environment.enterprise_template
  end

  settings_items :enable_contact_us, :type => :boolean, :default => true

  protected

  def default_homepage(attrs)
    EnterpriseHomepage.new(attrs)
  end

end
