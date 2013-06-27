require_dependency 'category'

class Category
  after_save_reindex [:articles, :profiles], :with => :delayed_job

  acts_as_searchable :fields => [
    # searched fields
    {:name => {:type => :text, :boost => 2.0}},
    {:path => :text}, {:slug => :text},
    {:abbreviation => :text}, {:acronym => :text},
    # filtered fields
    :parent_id,
    # ordered/query-boosted fields
    {:solr_plugin_name_sortable => :string},
  ]

  handle_asynchronously :solr_save

  private

  def solr_plugin_name_sortable
    name
  end
end
