Given /^the search index is empty$/ do
  ActsAsSolr::Post.execute(Solr::Request::Delete.new(:query => '*:*'))
end

# This could be merged with "the following categories"
Given /^the following categories as facets$/ do |table|
  ids = []
  table.hashes.each do |item|
    cat = Category.find_by_name(item[:name])
    if cat.nil?
      cat = Category.create!(:environment_id => Environment.default.id, :name => item[:name])
    end
    ids << cat.id
  end
  env = Environment.default
  env.solr_plugin_top_level_category_as_facet_ids = ids
  env.save!
end
