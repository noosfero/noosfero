Given /^the shopping basket is (enabled|disabled) on "([^""]*)"$/ do |status, name|
  status = status == 'enabled'
  enterprise = Enterprise.find_by_name(name) || Enterprise[name]
  settings = enterprise.shopping_cart_settings({:enabled => status})
  settings.save!
end

Given /^"([^""]*)" has the following delivery methods$/ do |name, table|
  enterprise = Enterprise.find_by_name(name) || Enterprise[name]
  table.hashes.map{|item| item.dup}.each do |item|
    delivery_method = enterprise.delivery_methods.build
    delivery_method.update_attributes(item)
  end
end
