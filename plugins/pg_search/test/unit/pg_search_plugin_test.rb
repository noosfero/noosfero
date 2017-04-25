require_relative '../../../../test/test_helper'

class PgSearchPluginTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(PgSearchPlugin)
    @plugin = PgSearchPlugin.new
  end

  attr_accessor :environment, :plugin

  should 'locate profile' do
    profile = fast_create(Profile, :name => 'John', :identifier => 'waterfall')
    assert_includes search(Profile, 'John'), profile
    assert_includes search(Profile, 'john'), profile
    assert_includes search(Profile, 'waterfall'), profile
    assert_includes search(Profile, 'water'), profile
  end

  should 'rank profiles based on the search entry' do
    profile1 = fast_create(Profile, :identifier => 'profile1', :name => 'debugger')
    profile2 = fast_create(Profile, :identifier => 'profile2', :name => 'profile admin debugger')
    profile3 = fast_create(Profile, :identifier => 'profile3', :name => 'admin debugger')
    profile4 = fast_create(Profile, :identifier => 'profile4', :name => 'simple user')
    assert_equal [profile2, profile3], search(Profile, 'profile admin deb')
  end

  # TODO This feature is available only on Postgresql 9.0
  # http://www.postgresql.org/docs/9.0/static/unaccent.html
  # should 'ignore accents' do
  #   profile = fast_create(Profile, :name => 'Produção', :identifier => 'colméia')
  #   assert_includes search(Profile, 'Produção'), profile
  #   assert_includes search(Profile, 'Producao'), profile
  #   assert_includes search(Profile, 'colméia'), profile
  #   assert_includes search(Profile, 'colmeia'), profile
  # end

  should 'get attribute identifier' do
    assert_equal "attribute-type", plugin.send(:attribute_identifier, Article, {:attribute => 'type'})
    assert_equal "attribute-editor", plugin.send(:attribute_identifier, Article, {:attribute => 'editor'})
  end

  should 'get relation identifier' do
    assert_equal "relation-category", plugin.send(:relation_identifier, Category, {})
    assert_equal "relation-acts_as_taggable_on/tag", plugin.send(:relation_identifier, Tag, {})
  end

  should 'get attribute label' do
    assert_equal "Types", plugin.send(:attribute_label, Article, {:attribute => 'type'})
    assert_equal "Editors", plugin.send(:attribute_label, Article, {:attribute => 'editor'})
  end

  should 'get relation label' do
    assert_equal "Categories", plugin.send(:relation_label, Category, {})
    assert_equal "Tags", plugin.send(:relation_label, Tag, {})
  end

  should 'get attribute option name' do
    assert_equal 'TextArticle', plugin.send(:attribute_option_name, 'TextArticle', Article, {:attribute => 'type'})
    assert_equal 'TinyMce', plugin.send(:attribute_option_name, 'TinyMce', Article, {:attribute => 'editor'})
  end

  should 'get friendly mime for content_type option name' do
    assert_equal 'ODT', plugin.send(:attribute_option_name, 'application/vnd.oasis.opendocument.text', Article, {:attribute => 'content_type'})
    assert_equal 'PDF', plugin.send(:attribute_option_name, 'application/pdf', Article, {:attribute => 'content_type'})
  end

  should 'get relation option name' do
    assert_equal 'Banana', plugin.send(:relation_option_name, 'Banana', Category, {})
    assert_equal 'Orange', plugin.send(:relation_option_name, 'Orange', Tag, {})
  end

  should 'get relation result label' do
    klass = mock
    klass.stubs(:name).returns('ActsAsTaggableOn::Tag')
    klass.stubs(:superclass).returns(ActiveRecord::Base)
    result = mock
    result.stubs(:class).returns(klass)
    result.stubs(:name).returns('cool')
    assert_equal 'cool', plugin.send(:relation_result_label, result)
  end

  should 'get relation result label for category' do
    parent_category = Category.create!(:name => 'Fruit', :environment => environment)
    result = Category.create!(:name => 'Orange', :parent => parent_category, :environment => environment)
    assert_equal 'Fruit &rarr; Orange', plugin.send(:relation_result_label, result)
  end

  should 'get attribute results' do
    scope = mock
    params = {:attribute => 'type'}
    query = mock
    query.stubs(:count).returns({'TextArticle' => 5, 'Event' => 8, 'Blog' => 3})
    klass = mock
    klass.stubs(:pg_search_plugin_attribute_facets).with(scope, params[:attribute]).returns(query)

    result = plugin.send(:attribute_results, klass, scope, params)

    assert_equal 'TextArticle', result[0][:name]
    assert_equal 'TextArticle', result[0][:value]
    assert_equal 5, result[0][:count]

    assert_equal 'Event', result[1][:name]
    assert_equal 'Event', result[1][:value]
    assert_equal 8, result[1][:count]

    assert_equal 'Blog', result[2][:name]
    assert_equal 'Blog', result[2][:value]
    assert_equal 3, result[2][:count]
  end

  should 'get relation results' do
    params = {:filter => :pg_search_plugin_articles_facets}
    scope = mock
    r1 = mock
    r1.stubs(:id).returns(1)
    r1.stubs(:counts).returns(5)
    r2 = mock
    r2.stubs(:id).returns(2)
    r2.stubs(:counts).returns(8)
    subquery = mock
    subquery.stubs(:order).returns([r1, r2])
    query = mock
    query.stubs(:select).returns(subquery)
    klass = mock
    klass.stubs(params[:filter]).with(scope).returns(query)
    klass.stubs(:table_name).returns('table_name')
    plugin.stubs(:relation_result_label).with(r1).returns('Result 1')
    plugin.stubs(:relation_result_label).with(r2).returns('Result 2')

    result = plugin.send(:relation_results, klass, scope, params)

    assert_equal 'Result 1', result[0][:name]
    assert_equal 1, result[0][:value]
    assert_equal 5, result[0][:count]

    assert_equal 'Result 2', result[1][:name]
    assert_equal 2, result[1][:value]
    assert_equal 8, result[1][:count]
  end

  should 'get generic attribute facet' do
    a11 = fast_create(TextArticle)
    a12 = fast_create(TextArticle)
    a13 = fast_create(TextArticle)
    a21 = fast_create(Event)
    a22 = fast_create(Event)
    a31 = fast_create(Blog)

    scope = Article.where(:id => [a11.id, a12.id, a13.id, a21.id, a22.id, a31.id])
    klass = Article
    selected_facets = {}
    kind = :attribute

    results = plugin.send(:generic_facet, klass, scope, selected_facets, kind, {:attribute => :type})
    text_article = results[:options].select {|opt| opt[:label] == 'TextArticle'}.first
    event = results[:options].select {|opt| opt[:label] == 'Event'}.first
    blog = results[:options].select {|opt| opt[:label] == 'Blog'}.first

    assert_equal 3, results[:options].count

    assert_equal 3, text_article[:count]
    assert_equal 'TextArticle', text_article[:value]

    assert_equal 2, event[:count]
    assert_equal 'Event', event[:value]

    assert_equal 1, blog[:count]
    assert_equal 'Blog', blog[:value]
  end

  should 'filter by facets' do
    c1 = fast_create(Category)
    c2 = fast_create(Category)
    profile = fast_create(Profile)

    a11 = fast_create(TextArticle, :profile_id => profile.id)
    a12 = fast_create(TextArticle, :profile_id => profile.id)
    a13 = fast_create(TextArticle, :profile_id => profile.id)
    a21 = fast_create(Event, :profile_id => profile.id)
    a22 = fast_create(Event, :profile_id => profile.id)
    a31 = fast_create(Blog, :profile_id => profile.id)

    a11.categories << c1
    a12.categories << c1
    a13.categories << c2
    a21.categories << c2
    a22.categories << c2
    a31.categories << c2

    a11.save!
    a12.save!
    a13.save!
    a21.save!
    a22.save!
    a31.save!

    scope = Article.where(:id => [a11.id, a12.id, a13.id, a21.id, a22.id, a31.id])
    facets = {'attribute-type' => [['Blog', '0'], ['Event', '0'], ['TextArticle', '1']], 'relation-category' => [[c1.id, '1'], [c2.id, '0']]}

    plugin.stubs(:register_search_facet_occurrence)
    assert_equivalent [a11, a12], plugin.send(:filter_by_facets, scope, facets)
  end

  should 'filter by periods' do
    a1 = fast_create(TextArticle, :created_at => 9.days.ago, :published_at => 6.days.ago)
    a2 = fast_create(TextArticle, :created_at => 8.days.ago, :published_at => 5.days.ago)
    a3 = fast_create(TextArticle, :created_at => 7.days.ago, :published_at => 4.days.ago)
    a4 = fast_create(TextArticle, :created_at => 6.days.ago, :published_at => 3.days.ago)
    a5 = fast_create(TextArticle, :created_at => 5.days.ago, :published_at => 2.days.ago)
    a6 = fast_create(TextArticle, :created_at => 4.days.ago, :published_at => 1.days.ago)

    scope = Article.where(:id => [a1.id, a2.id, a3.id, a4.id, a5.id, a6.id])
    periods = {:created_at => {'start_date' => 10.days.ago.to_s, 'end_date' => 5.days.ago.to_s}, :published_at => {'start_date' => 4.days.ago.to_s, 'end_date' => 1.day.ago.to_s}}

    assert_equivalent [a3, a4], plugin.send(:filter_by_periods, scope, periods)
  end

  should 'register attribute search facet occurrence' do
    occurrence = plugin.send(:register_search_facet_occurrence, environment, :articles, 'attribute', 'type', 'TextArticle')
    assert_equal 'articles', occurrence.asset
    assert_equal environment, occurrence.environment
    assert_equal 'type', occurrence.attribute_name
    assert_equal 'TextArticle', occurrence.value
    assert_nil occurrence.target
  end

  should 'register relation search facet occurrence' do
    category = Category.create!(:name => 'Fruit', :environment => environment)
    occurrence = plugin.send(:register_search_facet_occurrence, environment, :people, 'relation', 'category', category)
    assert_equal 'people', occurrence.asset
    assert_equal environment, occurrence.environment
    assert_equal category, occurrence.target
    assert_nil occurrence.attribute_name
    assert_nil occurrence.value
  end

  private

  def search(scope, query)
    scope.pg_search_plugin_search(query)
  end
end
