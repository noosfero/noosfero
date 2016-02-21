require_dependency 'product'

class Product

  include Noosfero::GeoRef

  # products x inputs
  # Fetches products the enterprise can be interested on buying based on the
  # inputs of said enterprise's products
  #   Ex:
  #     - Enterprise 1 has Product A that uses input X
  #     - Enterprise 2 has Product B that belongs to category X
  #   -> Enterprise 1 as a parameter to this scope would return product B
  scope :sniffer_plugin_suppliers_products, -> enterprise {
    select("DISTINCT products_2.*, 'product' as view")
      .joins('INNER JOIN inputs ON products.id = inputs.product_id')
      .joins('INNER JOIN categories ON inputs.product_category_id = categories.id')
      .joins('INNER JOIN products products_2 ON categories.id = products_2.product_category_id')
      .joins('INNER JOIN profiles ON profiles.id = products_2.profile_id')
      .where("products.profile_id = #{enterprise.id}")
      .where('profiles.public_profile = true AND profiles.visible = true')
      .where('profiles.enabled = true')
      .where("profiles.id <> #{enterprise.id}")
  }

  # inputs x products
  # Fetches the enterprise's products that can be of interest to other
  # enterprises based on their products' inputs
  #   Ex:
  #     - Enterprise 1 has Product A that belongs to category X
  #     - Enterprise 2 has Product B that uses input X
  #   -> Enterprise 1 as a parameter to this scope would return product A
  #   with an extra column `consumer_profile_id` equal to Enterprise 2 id
  scope :sniffer_plugin_consumers_products, -> enterprise {
    select("DISTINCT products_2.*, profiles.id as consumer_profile_id, 'product' as view")
      .joins('INNER JOIN inputs ON products.id = inputs.product_id')
      .joins('INNER JOIN categories ON inputs.product_category_id = categories.id')
      .joins('INNER JOIN products products_2 ON categories.id = products_2.product_category_id')
      .joins('INNER JOIN profiles ON profiles.id = products.profile_id')
      .where("products_2.profile_id = #{enterprise.id}")
      .where('profiles.public_profile = true AND profiles.visible = true')
      .where('profiles.enabled = true')
      .where("profiles.id <> #{enterprise.id}")
  }

  # interest x products
  # Fetches products the enterprise can be interested on buying based on the
  # buyer interests definded by this enterprise's admin
  #   Ex:
  #     - Enterprise 1 has category X as a buyer interest
  #     - Enterprise 2 has Product B that belongs to category X
  #   -> Enterprise 1 as a parameter to this scope would return product B
  scope :sniffer_plugin_interests_suppliers_products, -> profile {
    from("profiles sniffer")
      .select("DISTINCT products.*, 'product' as view")
      .joins("INNER JOIN sniffer_plugin_opportunities AS op ON sniffer.id = op.profile_id AND op.opportunity_type = 'ProductCategory'")
      .joins('INNER JOIN categories ON op.opportunity_id = categories.id')
      .joins('INNER JOIN products ON products.product_category_id = categories.id')
      .joins('INNER JOIN profiles ON products.profile_id = profiles.id')
      .where("sniffer.id = #{profile.id} AND products.profile_id <> #{profile.id}")
      .where('profiles.public_profile = true AND profiles.visible = true')
      .where('profiles.enabled = true')
      .where("profiles.id <> #{profile.id}")
  }

  # products x interests
  # Fetches products the enterprise can sell to others based on the buyer
  # interests definded by other enterprises' admins
  #   Ex:
  #     - Enterprise 1 has Product A that belongs to category X
  #     - Enterprise 2 has category X as a buyer interest
  #   -> Enterprise 1 as a parameter to this scope would return product A
  #   with an extra column `consumer_profile_id` equal to Enterprise 2 id
  scope :sniffer_plugin_interests_consumers_products, -> profile {
    select("DISTINCT products.*, profiles.id as consumer_profile_id, 'product' as view")
      .joins('INNER JOIN categories ON categories.id = products.product_category_id')
      .joins("INNER JOIN sniffer_plugin_opportunities as op ON categories.id = op.opportunity_id AND op.opportunity_type = 'ProductCategory'")
      .joins('INNER JOIN profiles ON op.profile_id = profiles.id')
      .where("products.profile_id = #{profile.id}")
      .where('profiles.public_profile = true AND profiles.visible = true')
      .where('profiles.enabled = true')
      .where("profiles.id <> #{profile.id}")
  }

  # knowledge x inputs
  scope :sniffer_plugin_knowledge_consumers_inputs, -> profile {
    select("DISTINCT products.*, articles.id AS knowledge_id, 'knowledge' as view")
      .joins('INNER JOIN inputs ON products.id = inputs.product_id')
      .joins("INNER JOIN article_resources ON article_resources.resource_id = inputs.product_category_id AND article_resources.resource_type = 'ProductCategory'")
      .joins('INNER JOIN articles ON article_resources.article_id = articles.id')
      .joins('INNER JOIN profiles ON products.profile_id = profiles.id')
      .where("articles.type = 'CmsLearningPlugin::Learning'")
      .where("articles.profile_id = #{profile.id}")
      .where("products.profile_id <> #{profile.id}")
  }

  # inputs x knowledge
  scope :sniffer_plugin_knowledge_suppliers_inputs, -> profile {
    select("DISTINCT products.*, profiles.id as supplier_profile_id, articles.id AS knowledge_id, 'knowledge' as view")
      .joins("INNER JOIN inputs ON products.id = inputs.product_id")
      .joins("INNER JOIN article_resources ON article_resources.resource_id = inputs.product_category_id AND article_resources.resource_type = 'ProductCategory'")
      .joins('INNER JOIN articles ON article_resources.article_id = articles.id')
      .joins('INNER JOIN profiles ON articles.profile_id = profiles.id')
      .where("articles.type = 'CmsLearningPlugin::Learning'")
      .where("articles.profile_id <> #{profile.id}")
      .where("products.profile_id = #{profile.id}")
  }

  # knowledge x interests
  scope :sniffer_plugin_knowledge_consumers_interests, -> profile {
    from('articles')
      .select("DISTINCT articles.id AS knowledge_id, op.opportunity_id AS product_category_id, profiles.id as profile_id, 'knowledge' as view")
      .joins('INNER JOIN article_resources ON articles.id = article_resources.article_id')
      .joins("INNER JOIN sniffer_plugin_opportunities as op ON article_resources.resource_id = op.opportunity_id AND op.opportunity_type = 'ProductCategory' AND article_resources.resource_type = 'ProductCategory'")
      .joins('INNER JOIN profiles ON op.profile_id = profiles.id')
      .where("articles.profile_id = #{profile.id}")
      .where('profiles.public_profile = true')
      .where('profiles.visible = true')
      .where('profiles.enabled = true')
      .where("profiles.id <> #{profile.id}")
  }

  # interests x knowledge
  scope :sniffer_plugin_knowledge_suppliers_interests, -> profile {
    from('articles')
      .select("DISTINCT articles.id AS knowledge_id, op.opportunity_id AS product_category_id, profiles.id as profile_id, 'knowledge' as view")
      .joins('INNER JOIN article_resources ON articles.id = article_resources.article_id')
      .joins("INNER JOIN sniffer_plugin_opportunities as op ON article_resources.resource_id = op.opportunity_id AND op.opportunity_type = 'ProductCategory' AND article_resources.resource_type = 'ProductCategory'")
      .joins('INNER JOIN profiles ON articles.profile_id = profiles.id')
      .where("articles.profile_id <> #{profile.id}")
      .where('profiles.public_profile = true')
      .where('profiles.visible = true')
      .where('profiles.enabled = true')
      .where("profiles.id = #{profile.id}")
  }

  # searches for products as supplies for a given product category
  scope :sniffer_plugin_products_from_category, -> product_category {
    select("*, 'product' as view")
      .where(product_category_id: product_category.id)
  }

end
