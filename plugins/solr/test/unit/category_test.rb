require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex articles after saving' do
    cat = Category.create!(:name => 'category 1', :environment_id => Environment.default.id)
    art = Article.create!(:name => 'something', :profile_id => fast_create(Person).id)
    art.add_category cat
    cat.reload

    solr_doc = art.to_solr_doc
    Article.any_instance.expects(:to_solr_doc).returns(solr_doc)
    cat.save!
  end
end
