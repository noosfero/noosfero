require_dependency 'article'
require_dependency 'pg_search_plugin/search_filters'

Article.class_eval do
  has_many :regions, -> { where(:type => ['Region', 'State', 'City']) }, :through => :article_categorizations, :source => :category

  scope :pg_search_plugin_by_attribute, -> attribute, value { select('articles.id').where("articles.#{attribute}" => value) }

  scope :pg_search_plugin_by_metadata,  -> attribute, value do
    select('articles.id').where("metadata->'custom_fields'->'#{attribute.to_s.to_slug}'->>'value' = '#{value}' AND " \
                                "metadata->'custom_fields'->'#{attribute.to_s.to_slug}'->>'public' = '1'")
  end

  scope :pg_search_plugin_by_metadata_period, -> attribute, start_date, end_date do
    if start_date.blank? && end_date.blank?
      all
    else
    # FIXME: stop using hardcoded dates when limits are blank
      start_date = start_date.blank? ? '2000-01-01' : start_date
      end_date   = end_date.blank?   ? '2100-01-01' : end_date
      where("to_date(metadata->'custom_fields'->'#{attribute.to_s.to_slug}'->>'value', 'YYYY-MM-DD') BETWEEN '#{start_date}' AND '#{end_date}' AND " \
            "metadata->'custom_fields'->'#{attribute.to_s.to_slug}'->>'public' = '1'")
    end
  end

  PgSearchPlugin::Filters = {:tag => :tags, :category => :categories, :region => :categories}
  include PgSearchPlugin::SearchFilters
end
