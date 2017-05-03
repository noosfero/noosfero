class CreateBlazerDefaultDashboardsAndQueries < ActiveRecord::Migration
  def change
    # Contents
    contents_dashboard = Blazer::Dashboard.create!(:name => 'Contents')
    contents_dashboard.queries << Blazer::Query.create!(:name => 'Contents by type', :statement => "SELECT type, COUNT(type) FROM articles GROUP BY type ORDER BY COUNT(type) DESC;", :data_source => 'main')
    contents_dashboard.queries << Blazer::Query.create!(:name => 'Contents by category', :statement => "SELECT articles.type, COUNT(articles.id) FROM articles INNER JOIN articles_categories ON articles.id = articles_categories.article_id WHERE articles_categories.category_id = {category_id} GROUP BY articles.type ORDER BY COUNT(articles.id) DESC", :data_source => 'main')
    contents_dashboard.queries << Blazer::Query.create!(:name => 'Contents by tag', :statement => "SELECT articles.type, COUNT(articles.id) FROM articles INNER JOIN taggings ON articles.id = taggings.taggable_id AND taggings.taggable_type = 'Article' WHERE taggings.tag_id = {tag_id} GROUP BY articles.type ORDER BY COUNT(articles.id) DESC", :data_source => 'main')
    contents_dashboard.queries << Blazer::Query.create!(:name => 'Contents created on time', :statement => "SELECT date_trunc({period}, created_at)::date AS period, type, COUNT(type) FROM articles WHERE created_at >= {start_time} AND created_at <= {end_time} GROUP BY period, type", :data_source => 'main')
    contents_dashboard.queries << Blazer::Query.create!(:name => 'Contents search term by score', :statement => "SELECT term, score FROM search_terms WHERE score > 0 AND asset = 'articles' ORDER BY score DESC;", :data_source => 'main')

    # Profiles
    profiles_dashboard = Blazer::Dashboard.create!(:name => 'Profiles')
    profiles_dashboard.queries << Blazer::Query.create!(:name => 'Profiles by type', :statement => "SELECT type, COUNT(type) FROM profiles GROUP BY type ORDER BY COUNT(type) DESC;", :data_source => 'main')
    profiles_dashboard.queries << Blazer::Query.create!(:name => 'Profiles by category', :statement => "SELECT profiles.type, COUNT(profiles.id) FROM profiles INNER JOIN categories_profiles ON profiles.id = categories_profiles.profile_id WHERE categories_profiles.category_id = {category_id} GROUP BY profiles.type ORDER BY COUNT(profiles.id) DESC", :data_source => 'main')
    profiles_dashboard.queries << Blazer::Query.create!(:name => 'Profiles by region', :statement => "SELECT profiles.type, COUNT(profiles.id) FROM profiles INNER JOIN categories_profiles ON profiles.id = categories_profiles.profile_id WHERE categories_profiles.category_id = {region_id} GROUP BY profiles.type ORDER BY COUNT(profiles.id) DESC", :data_source => 'main')
    profiles_dashboard.queries << Blazer::Query.create!(:name => 'Profiles created on time', :statement => "SELECT date_trunc({period}, created_at)::date AS period, type, COUNT(type) FROM profiles WHERE created_at >= {start_time} AND created_at <= {end_time} GROUP BY period, type", :data_source => 'main')
    profiles_dashboard.queries << Blazer::Query.create!(:name => 'Profiles by tag', :statement => "SELECT profiles.type, COUNT(profiles.id) FROM profiles INNER JOIN taggings ON profiles.id = taggings.taggable_id AND taggings.taggable_type = 'Profile' WHERE taggings.tag_id = {tag_id} GROUP BY profiles.type ORDER BY COUNT(profiles.id) DESC", :data_source => 'main')

    # Categories
    categories_dashboard = Blazer::Dashboard.create!(:name => 'Categories')
    categories_dashboard.queries << Blazer::Query.create!(:name => 'Categories on contents', :statement => "SELECT categories.name, COUNT(categories.id) FROM categories INNER JOIN articles_categories ON categories.id = articles_categories.category_id INNER JOIN articles ON articles_categories.article_id = articles.id WHERE categories.parent_id = {category_parent_id} AND articles_categories.virtual = FALSE AND categories.type IS NULL GROUP BY categories.id ORDER BY COUNT(categories.id) DESC;", :data_source => 'main')
    categories_dashboard.queries << Blazer::Query.create!(:name => 'Categories on profiles', :statement => "SELECT categories.name, COUNT(categories.id) FROM categories INNER JOIN categories_profiles ON categories.id = categories_profiles.category_id INNER JOIN profiles ON categories_profiles.profile_id = profiles.id WHERE categories.parent_id = {category_parent_id} AND categories.type IS NULL GROUP BY categories.id ORDER BY COUNT(categories.id) DESC;", :data_source => 'main')

    # Tags
    tags_dashboard = Blazer::Dashboard.create!(:name => 'Tags')
    tags_dashboard.queries << Blazer::Query.create!(:name => 'Tags on contents', :statement => "SELECT tags.name, COUNT(tags.id) FROM tags INNER JOIN taggings ON tags.id = taggings.tag_id INNER JOIN articles ON taggings.taggable_id = articles.id AND taggings.taggable_type='Article' GROUP BY tags.id ORDER BY COUNT(tags.id) DESC;", :data_source => 'main')
    tags_dashboard.queries << Blazer::Query.create!(:name => 'Tags on profiles', :statement => "SELECT tags.name, COUNT(tags.id) FROM tags INNER JOIN taggings ON tags.id = taggings.tag_id INNER JOIN profiles ON taggings.taggable_id = profiles.id AND taggings.taggable_type='Profile' GROUP BY tags.id ORDER BY COUNT(tags.id) DESC;", :data_source => 'main')
    tags_dashboard.queries << Blazer::Query.create!(:name => 'Tags created on time', :statement => "SELECT date_trunc({period}, created_at)::date AS period, COUNT(tags.id) FROM tags WHERE created_at >= {start_time} AND created_at <= {end_time} GROUP BY period", :data_source => 'main')

    # Regions
    regions_dashboard = Blazer::Dashboard.create!(:name => 'Regions')
    regions_dashboard.queries << Blazer::Query.create!(:name => 'Regions on profiles', :statement => "SELECT categories.name, COUNT(categories.id) FROM categories INNER JOIN categories_profiles ON categories.id = categories_profiles.category_id INNER JOIN profiles ON categories_profiles.profile_id = profiles.id WHERE categories.parent_id = {region_parent_id} AND categories.type = 'Region' GROUP BY categories.id ORDER BY COUNT(categories.id) DESC;", :data_source => 'main')

    # Search terms
    search_terms_dashboard = Blazer::Dashboard.create!(:name => 'Search Terms')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Search terms by score', :statement => "SELECT term, asset, score FROM search_terms WHERE score > 0 ORDER BY score DESC;", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Search terms by occurrences', :statement => "SELECT term, asset, COUNT(search_terms.id) FROM search_terms INNER JOIN search_term_occurrences on search_terms.id = search_term_occurrences.search_term_id GROUP BY search_terms.id ORDER BY COUNT(search_terms.id) DESC", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Contents search terms by score', :statement => "SELECT term, score FROM search_terms WHERE score > 0 AND asset = 'articles' ORDER BY score DESC;", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Contents search terms by occurrences', :statement => "SELECT term, COUNT(search_terms.id) FROM search_terms INNER JOIN search_term_occurrences on search_terms.id = search_term_occurrences.search_term_id where asset = 'articles' GROUP BY search_terms.id ORDER BY COUNT(search_terms.id) DESC", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'People search terms by score', :statement => "SELECT term, score FROM search_terms WHERE score > 0 AND asset = 'people' ORDER BY score DESC;", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'People search terms by occurrences', :statement => "SELECT term, COUNT(search_terms.id) FROM search_terms INNER JOIN search_term_occurrences on search_terms.id = search_term_occurrences.search_term_id where asset = 'people' GROUP BY search_terms.id ORDER BY COUNT(search_terms.id) DESC", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Communities search terms by score', :statement => "SELECT term, score FROM search_terms WHERE score > 0 AND asset = 'communities' ORDER BY score DESC;", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Communities search terms by occurrences', :statement => "SELECT term, COUNT(search_terms.id) FROM search_terms INNER JOIN search_term_occurrences on search_terms.id = search_term_occurrences.search_term_id where asset = 'communities' GROUP BY search_terms.id ORDER BY COUNT(search_terms.id) DESC", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Enterprises search terms by score', :statement => "SELECT term, score FROM search_terms WHERE score > 0 AND asset = 'enterprises' ORDER BY score DESC;", :data_source => 'main')
    search_terms_dashboard.queries << Blazer::Query.create!(:name => 'Enterprises search terms by occurrences', :statement => "SELECT term, COUNT(search_terms.id) FROM search_terms INNER JOIN search_term_occurrences on search_terms.id = search_term_occurrences.search_term_id where asset = 'enterprises' GROUP BY search_terms.id ORDER BY COUNT(search_terms.id) DESC", :data_source => 'main')
  end
end
