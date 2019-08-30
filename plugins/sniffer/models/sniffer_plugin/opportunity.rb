class SnifferPlugin::Opportunity < ApplicationRecord
  self.table_name = :sniffer_plugin_opportunities

  belongs_to :profile, optional: true

  belongs_to :opportunity, polymorphic: true, optional: true

  # for has_many :through
  belongs_to :product_category, -> {
    where "sniffer_plugin_opportunities.opportunity_type = ?", "ProductCategory"
  }, class_name: "::ProductsPlugin::ProductCategory", foreign_key: :opportunity_id, optional: true
  # getter
  def product_category
    opportunity_type == "ProductCategory" ? opportunity : nil
  end

  scope :product_categories, -> {
    where "sniffer_plugin_opportunities.opportunity_type = ?", "ProductCategory"
  }

  if defined? SolrPlugin
    extend SolrPlugin::ActsAsSearchable

    acts_as_searchable fields: [
      # searched fields
      # filtered fields
      # ordered/query-boosted fields
    ], include: [
      { product_category: { fields: [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation] } },
    ]

    handle_asynchronously :solr_save
  end

  delegate :lat, :lng, to: :product_category, allow_nil: true

  # delegate missing methods to opportunity
  def method_missing(method, *args, &block)
    if self.opportunity.respond_to? method
      self.opportunity.send method, *args, &block
    else
      super method, *args, &block
    end
  end

  def respond_to_with_opportunity?(method, p2 = true)
    respond_to_without_opportunity?(method, p2) || (self.opportunity && self.opportunity.respond_to?(method))
  end
  alias_method :respond_to_without_opportunity?, :respond_to?
  alias_method :respond_to?, :respond_to_with_opportunity?
end
