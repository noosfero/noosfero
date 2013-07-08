require "#{File.dirname(__FILE__)}/../test_helper"

class EnvironmentTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'find by contents from articles' do
    TestSolr.enable
    env = fast_create(Environment)
    env.enable_plugin(SolrPlugin)
    assert_nothing_raised do
      env.articles.find_by_contents('')[:results]
    end
  end

  should 'return more than 10 enterprises by contents' do
    TestSolr.enable
    Enterprise.destroy_all
    ('1'..'20').each do |n|
      Enterprise.create!(:name => 'test ' + n, :identifier => 'test_' + n)
    end

    assert_equal 20, environment.enterprises.find_by_contents('test')[:results].total_entries
  end
end
