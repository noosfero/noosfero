class SnifferPlugin::Profile < ActiveRecord::Base

  self.table_name = :sniffer_plugin_profiles

  belongs_to :profile, :class_name => '::Profile'

  has_many :opportunities, :class_name => 'SnifferPlugin::Opportunity', :foreign_key => :profile_id, :dependent => :destroy
  has_many :product_categories, :through => :opportunities, :source => :product_category, :foreign_key => :profile_id, :class_name => 'ProductCategory',
    :conditions => ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']

  validates_presence_of :profile

  attr_accessible :product_category_string_ids, :enabled

  def self.find_or_create profile
    sniffer = SnifferPlugin::Profile.find_by_profile_id profile.id
    if sniffer.nil?
      sniffer = SnifferPlugin::Profile.new
      sniffer.profile = profile
      sniffer.enabled = true
      sniffer.save!
    end
    sniffer
  end

  def product_category_string_ids
    ''
  end

  def product_category_string_ids=(ids)
    ids = ids.split(',')
    self.product_categories = []
    self.product_categories = ProductCategory.find(ids)
    self.opportunities.
         find(:all, :conditions => {:opportunity_id => ids}).each do |o|
           o.opportunity_type = 'ProductCategory'
           o.save!
         end
  end

  def profile_input_categories
    profile.input_categories
  end

  def profile_product_categories
    profile.product_categories
  end

  def all_categories
    (profile_product_categories + profile_input_categories + product_categories).uniq
  end

  def suppliers_products
    products = []

    products += Product.sniffer_plugin_suppliers_products profile if profile.enterprise?
    products += Product.sniffer_plugin_interests_suppliers_products profile
    if defined?(CmsLearningPlugin)
      products += Product.sniffer_plugin_knowledge_suppliers_inputs profile
      products += Product.sniffer_plugin_knowledge_suppliers_interests profile
    end

    products
  end

  def consumers_products
    products = []

    products += Product.sniffer_plugin_consumers_products profile if profile.enterprise?
    products += Product.sniffer_plugin_interests_consumers_products profile
    if defined?(CmsLearningPlugin)
      products += Product.sniffer_plugin_knowledge_consumers_inputs profile
      products += Product.sniffer_plugin_knowledge_consumers_interests profile
    end

    products
  end

end
