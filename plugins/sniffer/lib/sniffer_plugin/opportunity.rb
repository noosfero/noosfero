class SnifferPlugin::Opportunity < ActiveRecord::Base

  self.table_name = :sniffer_plugin_opportunities

  belongs_to :sniffer_profile, :class_name => 'SnifferPlugin::Profile', :foreign_key => :profile_id
  has_one :profile, :through => :sniffer_profile

  belongs_to :opportunity, :polymorphic => true

  # for has_many :through
  belongs_to :product_category, :class_name => 'ProductCategory', :foreign_key => :opportunity_id,
    :conditions => ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']
  # getter
  def product_category
    opportunity_type == 'ProductCategory' ? opportunity : nil
  end

  scope :product_categories, {
    :conditions => ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']
  }

  if defined? SolrPlugin
    acts_as_searchable :fields => [
        # searched fields
        # filtered fields
        # ordered/query-boosted fields
      ], :include => [
        {:product_category => {:fields => [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
      ]

    handle_asynchronously :solr_save
  end

end
