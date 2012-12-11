require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex articles after saving' do
    profile = create(Person, :name => 'something', :user_id => fast_create(User).id)
    art = profile.articles.build(:name => 'something')
    Profile.expects(:solr_batch_add).with(includes(art))
    profile.save!
  end
end
