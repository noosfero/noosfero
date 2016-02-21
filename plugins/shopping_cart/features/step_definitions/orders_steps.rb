Given /^the following purchase from "([^""]*)" on "([^""]*)" that is "([^""]*)"$/ do |consumer_identifier, enterprise_identifier, status, table|
  consumer = Person.find_by(name: consumer_identifier) || Person[consumer_identifier]
  enterprise = Enterprise.find_by(name: enterprise_identifier) || Enterprise[enterprise_identifier]
  order = OrdersPlugin::Purchase.new(:profile => enterprise, :consumer => consumer, :status => status)

  table.hashes.map{|item| item.dup}.each do |item|
    product = enterprise.products.find_by name: item[:product]
    item = order.items.build({:product => product, :name => item[:product], :quantity_consumer_ordered => item[:quantity], :price => item[:price]})
    item.order = order
  end

  order.save!
end
