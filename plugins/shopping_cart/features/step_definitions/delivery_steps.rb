Given /^"([^""]*)" has the following delivery methods$/ do |name, table|
  enterprise = Enterprise.find_by(name: name) || Enterprise[name]
  table.hashes.map{|item| item.dup}.each do |item|
    delivery_method = enterprise.delivery_methods.build
    delivery_method.update_attributes(item)
  end
end
