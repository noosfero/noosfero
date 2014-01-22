require "#{File.dirname(__FILE__)}/../test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
    @product_category = fast_create(ProductCategory, :name => 'Products')
    @profile = fast_create(Enterprise)
  end

  attr_accessor :environment, :product_category, :profile

  should 'reindex enterprise after saving' do
    ent = fast_create(Enterprise)
    cat = fast_create(ProductCategory)
    prod = Product.create!(:name => 'something', :profile_id => ent.id, :product_category_id => cat.id)
    Product.expects(:solr_batch_add).with([ent])
    prod.save!
  end

  should 'act as faceted' do
    s = fast_create(State, :acronym => 'XZ')
    c = fast_create(City, :name => 'Tabajara', :parent_id => s.id)
    ent = fast_create(Enterprise, :region_id => c.id)
    cat = fast_create(ProductCategory, :name => 'hardcore')
    p = Product.create!(:name => 'black flag', :profile_id => ent.id, :product_category_id => cat.id)
    pq = p.product_qualifiers.create!(:qualifier => fast_create(Qualifier, :name => 'qualifier'),
                                      :certifier => fast_create(Certifier, :name => 'certifier'))
    assert_equal 'Related products', Product.facet_by_id(:solr_plugin_f_category)[:label]
    assert_equal ['Tabajara', ', XZ'], Product.facet_by_id(:solr_plugin_f_region)[:proc].call(p.send(:solr_plugin_f_region))
    assert_equal ['qualifier', ' cert. certifier'], Product.facet_by_id(:solr_plugin_f_qualifier)[:proc].call(p.send(:solr_plugin_f_qualifier).last)
    assert_equal 'hardcore', p.send(:solr_plugin_f_category)
    assert_equal "solr_plugin_category_filter:#{cat.id}", Product.facet_category_query.call(cat)
  end

  should 'act as searchable' do
    TestSolr.enable
    s = fast_create(State, :acronym => 'XZ')
    c = fast_create(City, :name => 'Tabajara', :parent_id => s.id)
    ent = fast_create(Enterprise, :region_id => c.id, :name => "Black Sun")
    category = fast_create(ProductCategory, :name => "homemade", :acronym => "hm", :abbreviation => "homey")
    p = Product.create!(:name => 'bananas syrup', :description => 'surrounded by mosquitos', :profile_id => ent.id,
                        :product_category_id => category.id)
    qual = Qualifier.create!(:name => 'qualificador', :environment_id => Environment.default.id)
    cert = Certifier.create!(:name => 'certificador', :environment_id => Environment.default.id)
    pq = p.product_qualifiers.create!(:qualifier => qual,	:certifier => cert)
    p.qualifiers.reload
    p.certifiers.reload
    p.save!
    # fields
    assert_includes Product.find_by_contents('bananas')[:results].docs, p
    assert_includes Product.find_by_contents('mosquitos')[:results].docs, p
    assert_includes Product.find_by_contents('homemade')[:results].docs, p
    # filters
    assert_includes Product.find_by_contents('bananas', {}, { :filter_queries => ["solr_plugin_public:true"]})[:results].docs, p
    assert_not_includes Product.find_by_contents('bananas', {}, { :filter_queries => ["solr_plugin_public:false"]})[:results].docs, p
    assert_includes Product.find_by_contents('bananas', {}, { :filter_queries => ["environment_id:\"#{Environment.default.id}\""]})[:results].docs, p
    # includes
    assert_includes Product.find_by_contents("homemade")[:results].docs, p
    assert_includes Product.find_by_contents(category.slug)[:results].docs, p
    assert_includes Product.find_by_contents("hm")[:results].docs, p
    assert_includes Product.find_by_contents("homey")[:results].docs, p
    assert_includes Product.find_by_contents("Tabajara")[:results].docs, p
    assert_includes Product.find_by_contents("Black Sun")[:results].docs, p
    assert_includes Product.find_by_contents("qualificador")[:results].docs, p
    assert_includes Product.find_by_contents("certificador")[:results].docs, p
  end

  should 'boost name matches' do
    TestSolr.enable
    ent = fast_create(Enterprise)
    cat = fast_create(ProductCategory)
    in_desc = Product.create!(:name => 'something', :profile_id => ent.id, :description => 'bananas in the description!',
                              :product_category_id => cat.id)
    in_name = Product.create!(:name => 'bananas in the name!', :profile_id => ent.id, :product_category_id => cat.id)
    assert_equal [in_name, in_desc], Product.find_by_contents('bananas')[:results].docs
  end

  should 'boost search results that include an image' do
    TestSolr.enable
    product_without_image = Product.create!(:name => 'product without image', :product_category => product_category,
                                            :profile_id => profile.id)
    product_with_image = Product.create!(:name => 'product with image', :product_category => product_category,
                                         :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')},
                                         :profile_id => profile.id)
    assert_equal [product_with_image, product_without_image], Product.find_by_contents('product image')[:results].docs
  end

  should 'boost search results that include qualifier' do
    TestSolr.enable
    product_without_q = Product.create!(:name => 'product without qualifier', :product_category => product_category,
                                        :profile_id => profile.id)
    product_with_q = Product.create!(:name => 'product with qualifier', :product_category => product_category,
                                     :profile_id => profile.id)
    product_with_q.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => nil)
    product_with_q.save!

    assert_equal [product_with_q, product_without_q], Product.find_by_contents('product qualifier')[:results].docs
  end

  should 'boost search results with open price' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => product_category, :profile_id => profile.id, :price => 100)
    open_price = Product.new(:name => 'product 2', :product_category => product_category, :profile_id => profile.id, :price => 100)
    open_price.inputs << Input.new(:product => open_price, :product_category_id => product_category.id, :amount_used => 10, :price_per_unit => 10)
    open_price.save!

    assert_equal [open_price, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost search results with solidarity inputs' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => product_category, :profile_id => profile.id)
    perc_50 = Product.create!(:name => 'product 2', :product_category => product_category, :profile_id => profile.id)
    Input.create!(:product_id => perc_50.id, :product_category_id => product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => perc_50.id, :product_category_id => product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    perc_50.save!
    perc_75 = Product.create!(:name => 'product 3', :product_category => product_category, :profile_id => profile.id)
    Input.create!(:product_id => perc_75.id, :product_category_id => product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    Input.create!(:product_id => perc_75.id, :product_category_id => product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => perc_75.id, :product_category_id => product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => perc_75.id, :product_category_id => product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    perc_75.save!

    assert_equal [perc_75, perc_50, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost available search results' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => product_category, :profile_id => profile.id)
    product.available = false
    product.save!
    product2 = Product.create!(:name => 'product 2', :product_category => product_category, :profile_id => profile.id)
    product2.available = true
    product2.save!

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost search results created updated recently' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => product_category, :profile_id => profile.id)
    product.update_attribute :created_at, Time.now - 10.day
    product2 = Product.create!(:name => 'product 2', :product_category => product_category, :profile_id => profile.id)

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost search results with description' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => product_category, :profile_id => profile.id,
                              :description => '')
    product2 = Product.create!(:name => 'product 2', :product_category => product_category, :profile_id => profile.id,
                               :description => 'a small description')

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost if enterprise is enabled' do
    TestSolr.enable
    ent = Enterprise.create!(:name => 'ent', :identifier => 'ent', :enabled => false)
    product = Product.create!(:name => 'product 1', :product_category => product_category, :profile_id => ent.id)
    product2 = Product.create!(:name => 'product 2', :product_category => product_category, :profile_id => profile.id)

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'combine different boost types' do
    TestSolr.enable
    product = Product.create!(:name => 'product', :product_category => product_category,	:profile_id => profile.id)
    image_only = Product.create!(:name => 'product with image', :product_category => product_category,
                                 :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')},
                                 :profile_id => profile.id)
    qual_only = Product.create!(:name => 'product with qualifier', :product_category => product_category,
                                :profile_id => profile.id)
    img_and_qual = Product.create!(:name => 'product with image and qualifier', :product_category => product_category,
                                   :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')},
                                   :profile_id => profile.id)
    qual_only.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => nil)
    img_and_qual.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => nil)
    qual_only.save!
    img_and_qual.save!

    assert_equal [img_and_qual, image_only, qual_only, product], Product.find_by_contents('product')[:results].docs
  end

  should 'be indexed by category full name' do
    TestSolr.enable
    parent_cat = fast_create(ProductCategory, :name => 'Parent')
    prod_cat = fast_create(ProductCategory, :name => 'Category1', :parent_id => parent_cat.id)
    prod_cat2 = fast_create(ProductCategory, :name => 'Category2')
    p = Product.create(:name => 'a test', :product_category => prod_cat, :profile_id => @profile.id)
    p2 = Product.create(:name => 'another test', :product_category => prod_cat2, :profile_id => @profile.id)

    r = Product.find_by_contents('Parent')[:results].docs
    assert_includes r, p
    assert_not_includes r, p2
  end

  should 'index by schema name when database is postgresql' do
    TestSolr.enable
    uses_postgresql 'schema_one'
    p1 = Product.create!(:name => 'some thing', :product_category => @product_category, :profile_id => @profile.id)
    assert_equal [p1], Product.find_by_contents('thing')[:results].docs
    uses_postgresql 'schema_two'
    p2 = Product.create!(:name => 'another thing', :product_category => @product_category, :profile_id => @profile.id)
    assert_not_includes Product.find_by_contents('thing')[:results], p1
    assert_includes Product.find_by_contents('thing')[:results], p2
    uses_postgresql 'schema_one'
    assert_includes Product.find_by_contents('thing')[:results], p1
    assert_not_includes Product.find_by_contents('thing')[:results], p2
    uses_sqlite
  end

  should 'not index by schema name when database is not postgresql' do
    TestSolr.enable
    uses_sqlite
    p1 = Product.create!(:name => 'some thing', :product_category => @product_category, :profile_id => @profile.id)
    assert_equal [p1], Product.find_by_contents('thing')[:results].docs
    p2 = Product.create!(:name => 'another thing', :product_category => @product_category, :profile_id => @profile.id)
    assert_includes Product.find_by_contents('thing')[:results], p1
    assert_includes Product.find_by_contents('thing')[:results], p2
  end
end

