# An enterprise is a kind of organization. According to the system concept,
# only enterprises can offer products and services.
class Enterprise < Organization

  N_('Enterprise')

  has_many :products, :dependent => :destroy

  extra_data_for_index :product_categories

  def product_categories
    products.map{|p| p.category_full_name}
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

  def code
    ("%06d" % id) + Digest::MD5.hexdigest(id.to_s)[0..5]
  end

  def self.return_by_code(code)
    id = code[0..5].to_i
    md5 = code[6..11]
    return unless md5 == Digest::MD5.hexdigest(id.to_s)[0..5]

    Enterprise.find(id)
  end

end
