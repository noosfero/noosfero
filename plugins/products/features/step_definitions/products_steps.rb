Then /^I should be taken to "([^\"]*)" product page$/ do |product_name|
  product = Product.find_by name: product_name
  path = url_for(product.enterprise.public_profile_url.merge(controller: 'products_plugin/page', action: 'show', id: product, only_path: true))
  if response.class.to_s == 'Webrat::SeleniumResponse'
    URI.parse(response.selenium.get_location).path.should == path_to(path)
  else
    URI.parse(current_url).path.should == path_to(path)
  end
end

Then /^I should see ([^\"]*)'s product image$/ do |product_name|
  p = Product.find_by name: product_name
  path = url_for(p.enterprise.public_profile_url.merge(controller: 'products_plugin/page', action: 'show', id: p))

  with_scope('.zoomable-image') do
    page.should have_xpath("a[@href=\"#{path}\"][@class='search-image-pic']")
  end
end

Then /^I should not see ([^\"]*)'s product image$/ do |product_name|
  p = Product.find_by name: product_name
  path = url_for(p.enterprise.public_profile_url.merge(controller: 'products_plugin/page', action: 'show', id: p))

  with_scope('.zoomable-image') do
    page.should have_no_xpath("a[@href=\"#{path}\"][@class='search-image-pic']")
  end
end

Given /^the following products?$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    owner = Enterprise[data.delete("owner")]
    category = Category.find_by slug: data.delete("category").to_slug
    data.merge!(enterprise: owner, product_category: category)
    if data[:img]
      img = Image.create!(uploaded_data: fixture_file_upload('/files/'+data.delete("img")+'.png', 'image/png'))
      data.merge!(image_id: img.id)
    end
    if data[:qualifier]
      qualifier = Qualifier.find_by name: data.delete("qualifier")
      data.merge!(qualifiers: [qualifier])
    end
    product = Product.create!(data, without_protection: true)
  end
end

Given /^the following inputs?$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    product = Product.find_by name: data.delete("product")
    category = Category.find_by slug: data.delete("category").to_slug
    unit = Unit.find_by singular: data.delete("unit")
    solidary = data.delete("solidary")
    input = Input.create!(data.merge(product: product, product_category: category, unit: unit,
                                     is_from_solidarity_economy: solidary), without_protection: true)
    input.update_attribute(:position,  data['position'])
  end
end

Given /^the following production costs?$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    owner_type = item.delete('owner')
    owner = owner_type == 'environment' ? Environment.default : Profile[owner_type]
    ProductionCost.create!(item.merge(owner: owner))
  end
end

Given /^the following price details?$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    product = Product.find_by name: item.delete('product')
    production_cost = ProductionCost.find_by name: item.delete('production_cost')
    product.price_details.create!(item.merge(production_cost: production_cost))
  end
end

Given /^the following qualifiers$/ do |table|
  table.hashes.each do |row|
    Qualifier.create!(row.merge(environment_id: 1), without_protection: true)
  end
end

Given /^the following certifiers$/ do |table|
  table.hashes.each do |row|
    row = row.dup
    qualifiers_list = row.delete("qualifiers")
    if qualifiers_list
      row["qualifiers"] = qualifiers_list.split(', ').map{ |i| Qualifier.find_by name: i }
    end
    Certifier.create!(row.merge(environment_id: 1), without_protection: true)
  end
end

