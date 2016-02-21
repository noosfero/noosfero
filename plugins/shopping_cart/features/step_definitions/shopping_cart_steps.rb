Given /^the shopping basket is (enabled|disabled) on "([^""]*)"$/ do |status, name|
  status = status == 'enabled'
  enterprise = Enterprise.find_by(name: name) || Enterprise[name]
  settings = enterprise.shopping_cart_settings({:enabled => status})
  settings.save!
end

