require_relative '../test_helper'

class ArticleTest < ActiveSupport::TestCase
  
  def setup
    @profile = fast_create(Community)
    @track = create_track('track', @profile)
    @step = CommunityTrackPlugin::Step.create!(:name => 'Step', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
  end

  should 'inherit accept_comments from parent if it is a step' do
    @step.accept_comments = true
    @step.save!
    article = Article.create!(:parent => @step, :profile => @profile, :accept_comments => false, :name => "article")
    assert article.accept_comments
  end

  should 'do nothing if parent is not a step' do
    folder = fast_create(Folder, :profile_id => @profile.id)
    article = Article.create!(:parent => folder, :profile => @profile, :accept_comments => false, :name => "article")
    refute article.accept_comments
  end

end
