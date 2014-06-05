require 'test_helper'

class PgSearchPluginTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(PgSearchPlugin)
  end

  should 'locate profile' do
    profile = fast_create(Profile, :name => 'John', :identifier => 'waterfall')
    assert_includes search(Profile, 'John'), profile
    assert_includes search(Profile, 'john'), profile
    assert_includes search(Profile, 'waterfall'), profile
    assert_includes search(Profile, 'water'), profile
  end

  should 'locate one or more profiles' do
    profile1 = fast_create(Profile, :identifier => 'administrator')
    profile2 = fast_create(Profile, :identifier => 'debugger')
    assert_includes search(Profile, 'admin deb'), profile1
    assert_includes search(Profile, 'admin deb'), profile2
  end

  should 'locate profile escaping special characters' do
    profile = fast_create(Profile, :name => 'John', :identifier => 'waterfall')
    assert_includes search(Profile, ') ( /\/\/\/\/\ o_o oOo o_o /\/\/\/\/\ ) ((tx waterfall)'), profile
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

  should 'check if filter option is defined' do
    plugin = PgSearchPlugin.new
    assert plugin.find_by_contents('asset', Profile, 'query', {:page => 1})
  end

  private

  def search(scope, query)
    scope.pg_search_plugin_search(query)
  end
end
