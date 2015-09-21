Given /^the shopping basket is (enabled|disabled) on "([^""]*)"$/ do |status, name|
  status = status == 'enabled'
  enterprise = Enterprise.find_by_name(name) || Enterprise[name]
  settings = enterprise.shopping_cart_settings({:enabled => status})
  settings.save!
end

Given /^the following purchase from "([^""]*)" on "([^""]*)" that is "([^""]*)"$/ do |consumer_identifier, enterprise_identifier, status, table|
  consumer = Person.find_by_name(consumer_identifier) || Person[consumer_identifier]
  enterprise = Enterprise.find_by_name(enterprise_identifier) || Enterprise[enterprise_identifier]
  order = OrdersPlugin::Purchase.new(:profile => enterprise, :consumer => consumer, :status => status)

  table.hashes.map{|item| item.dup}.each do |item|
    product = enterprise.products.find_by_name item[:product]
    item = order.items.build({:product => product, :name => item[:product], :quantity_consumer_ordered => item[:quantity], :price => item[:price]})
    item.order = order
  end

  order.save!
end
