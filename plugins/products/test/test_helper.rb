require 'test_helper'

module Noosfero::Factory

  def defaults_for_products_plugin_product_category
    defaults_for_category
  end

  def defaults_for_products_plugin_product
    { name: 'Product ' + factory_num_seq.to_s }
  end

  def defaults_for_products_plugin_production_cost
    { name: 'Production cost ' + factory_num_seq.to_s }
  end

  def defaults_for_products_plugin_qualifier
    { name: 'Qualifier ' + factory_num_seq.to_s, environment_id: 1 }
  end
  def defaults_for_qualifier
    defaults_for_products_plugin_qualifier
  end

  def defaults_for_products_plugin_certifier
    defaults_for_qualifier.merge({ name: 'Certifier ' + factory_num_seq.to_s })
  end

  def defaults_for_products_plugin_input
    { }
  end

  def defaults_for_products_plugin_price_detail
    { }
  end

  def defaults_for_unit
    { singular: 'Litre', plural: 'Litres', environment_id: 1 }
  end

end
