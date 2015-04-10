require "#{File.dirname(__FILE__)}/../../../../test/test_helper"

class SnifferMapTest < ActionController::IntegrationTest

  fixtures :users, :profiles

  def url_plugin_myprofile(profile, action, opt={})
    url_for({ :controller => 'sniffer_plugin_myprofile',
              :action => action,
              :profile => profile.identifier }.merge(opt))
  end

  def setup
    Environment.default.enable_plugin('SnifferPlugin')
    @e = []; @c = []; @p = []

    # Create 4 enterprises:
    4.times do |i| n = (i+=1).to_s
      @e[i] = fast_create(Enterprise,
        :identifier => 'ent'+n, :name => 'enterprise'+n, :lat => 0, :lng => 0
      )
    end
    # Create 2 products to each enterprise with its own category:
    8.times do |i| n = (i+=1).to_s
      @c[i] = fast_create(ProductCategory, :name => 'Category'+n)
      @p[i] = fast_create(Product,
        :product_category_id => @c[i].id, :profile_id => @e[(i+1)/2].id
      )
    end
    # Build relationship between products, by defining production inputs:
    #  ent1   ent2   ent3   ent4
    # ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
    #   p1◄━┭──p3  ╭─►p5  ┌─►p7
    #       │┏━━━━━┷━━━━━━┥
    #       ╰╂─────╮      │
    #   p2━━━┛ p4  ╰──p6  ╰─►p8
    #
    @p[1].inputs.build.product_category = @p[3].product_category
    @p[1].inputs.build.product_category = @p[6].product_category
    @p[5].inputs.build.product_category = @p[2].product_category
    @p[7].inputs.build.product_category = @p[2].product_category
    @p[8].inputs.build.product_category = @p[2].product_category
    @p.each {|product| product.save! if product }

    # Test the sniffer map page as admin:
    login('ze', 'test')
  end

  should 'localize suppliers and consumers on page load' do
    get url_plugin_myprofile(@e[1], :search)
    js_e = []

    # Localize the loader call:
    re = /sniffer\.search\.map\.load\((\{.*?\})\);/m
    assert_match(re, @response.body)

    # Read the json data provided to the loader:
    js_profiles = JSON.parse(re.match(@response.body)[1])['profiles']
    # Get the data provided by the JSON to each related enterprise:
    3.times do |i| i+=2
      js_e[i] = {}
      js_e[i][:supply] = js_profiles.detect{|ent| ent['id']==@e[i].id}['suppliersProducts']
      js_e[i][:consum] = js_profiles.detect{|ent| ent['id']==@e[i].id}['consumersProducts']
    end

    # Related Enterprise 2
    assert_equal 1, js_e[2][:supply].length
    assert_equal 0, js_e[2][:consum].length
    assert_equal @p[3].id, js_e[2][:supply][0]['id']

    # Related Enterprise 3
    assert_equal 1, js_e[3][:supply].length
    assert_equal 1, js_e[3][:consum].length
    assert_equal @p[2].id, js_e[3][:consum][0]['id']
    assert_equal @p[6].id, js_e[3][:supply][0]['id']

    # Related Enterprise 4
    assert_equal 0, js_e[4][:supply].length
    assert_equal 1, js_e[4][:consum].length
    assert_equal @p[2].id, js_e[4][:consum][0]['id']
  end

  should 'create balloon on map for a supplier' do
    post url_plugin_myprofile(@e[1], :map_balloon, :id => @e[2].id),
    {"suppliersProducts" => {
      0=>{
      "product_category_id" => @c[1].id,
      "id" => @p[3].id,
      "view" => 'product',
      "profile_id" => @e[2].id
      }},
     "consumersProducts" => [],
     "id" => @e[2].id
    }
    assert_response 200
    assert_tag :tag => 'a', :attributes => { :href => '/profile/ent2'}, :content => @e[2].name
    assert_tag :tag => 'a', :attributes => { :href => url_for(@p[3].url) }, :content => @p[3].name
    assert_select '.consumer-products', nil, 'consumer-products must to exist'
    assert_select '.consumer-products *', 0, 'consumer-products must to be empty for @c1 on @e2'
  end

  should 'create balloon on map for a consumer' do
    post url_plugin_myprofile(@e[1], :map_balloon, :id => @e[4].id),
    {"suppliersProducts" => [],
     "consumersProducts" => {
      0=>{
      "product_category_id" => @c[2].id,
      "id" => @p[2].id,
      "view" => 'product',
      "profile_id" => @e[4].id
      }},
     "id" => @e[4].id
    }
    assert_response 200
    assert_tag :tag => 'a', :attributes => { :href => '/profile/ent4'}, :content => @e[4].name
    assert_tag :tag => 'a', :attributes => { :href => url_for(@p[2].url) }, :content => @p[2].name
    assert_select '.suppliers-products', nil, 'suppliers-products must to exist'
    assert_select '.suppliers-products *', 0, 'suppliers-products must to be empty for @c2 on @e4'
  end

  should 'create balloon on map for a supplier and consumer' do
    post url_plugin_myprofile(@e[1], :map_balloon, :id => @e[3].id),
    {"suppliersProducts" => {
      0=>{
      "product_category_id" => @c[1].id,
      "id" => @p[6].id,
      "view" => 'product',
      "profile_id" => @e[3].id
      }},
     "consumersProducts" => {
      0=>{
      "product_category_id" => @c[2].id,
      "id" => @p[2].id,
      "view" => 'product',
      "profile_id" => @e[3].id
      }},
     "id" => @e[3].id
    }
    assert_response 200
    assert_tag :tag => 'a', :attributes => { :href => '/profile/ent3'}, :content => @e[3].name
    assert_select ".suppliers-products a[href=#{url_for(@p[6].url)}]", @p[6].name,
      "Can't find link to @p6 (#{@p[6].name})."
    assert_select ".consumer-products a[href=#{url_for(@p[2].url)}]", @p[2].name,
      "Can't find link to @p2 (#{@p[2].name})."
  end

  should 'search for more suppliers and consumers' do
    get url_plugin_myprofile(@e[1], :product_category_search, :term => @c[1].name)
    assert_response 200
    json = JSON.parse @response.body
    assert_equal [{'label'=>@c[1].name, 'value'=>@c[1].id}], json

    get url_plugin_myprofile(@e[1], :product_category_search, :term => 'cat')
    assert_response 200
    json = JSON.parse @response.body
    assert_equal 8, json.length
  end

  should 'map buyer interests' do
    # crate an entreprise
    acme = fast_create(Enterprise,
      :identifier => 'acme', :name => 'ACME S.A.', :lat => 0, :lng => 0
    )
    # get the extended sniffer profile for the enterprise:
    sniffer_acme = SnifferPlugin::Profile.find_or_create acme
    sniffer_acme.product_category_string_ids = "#{@c[1].id},#{@c[4].id}"
    sniffer_acme.enabled = true
    sniffer_acme.save!

    # visit the map page:
    get url_plugin_myprofile(acme, :search)

    # Localize the loader call:
    re = /sniffer\.search\.map\.load\((\{.*?\})\);/m
    assert_match(re, @response.body)

    # Read the json data provided to the loader:
    js_profiles = JSON.parse(re.match(@response.body)[1])['profiles']
    e1, e2 = js_profiles.sort{|a,b| a['name'] <=> b['name'] }
    assert_equal 'enterprise1', e1['name']
    assert_equal 'enterprise2', e2['name']
    assert_equal 1, e1['suppliersProducts'].length
    assert_equal 0, e1['consumersProducts'].length
    assert_equal 1, e2['suppliersProducts'].length
    assert_equal 0, e2['consumersProducts'].length
    assert_equal @p[1].id, e1['suppliersProducts'][0]['id']
    assert_equal @p[4].id, e2['suppliersProducts'][0]['id']
    assert_equal @c[1].id, e1['suppliersProducts'][0]['product_category_id']
    assert_equal @c[4].id, e2['suppliersProducts'][0]['product_category_id']
  end

end
