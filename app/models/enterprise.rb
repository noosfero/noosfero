# An enterprise is a kind of organization. According to the system concept,
# only enterprises can offer products and services.
class Enterprise < Organization

  N_('Enterprise')

  has_many :products, :dependent => :destroy

  extra_data_for_index :product_categories

  def product_categories
    products.map{|p| p.product_category.full_name.split('/') }.join(' ')
  end

end
