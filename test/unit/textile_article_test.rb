require File.dirname(__FILE__) + '/../test_helper'

class TextileArticleTest < Test::Unit::TestCase
  
  def setup
    @profile = create_user('testing').person
  end
  attr_reader :profile

  should 'provide a proper short description' do
    assert_kind_of String, TextileArticle.short_description
  end

  should 'provide a proper description' do
    assert_kind_of String, TextileArticle.description
  end

  should 'convert Textile to HTML' do
    assert_equal '<p><strong>my text</strong></p>', TextileArticle.new(:body => '*my text*').to_html
  end

  should 'accept empty body' do
    a = TextileArticle.new
    a.expects(:body).returns(nil)
    assert_nothing_raised do
      assert_equal '', a.to_html
    end
  end

  should 'notifiable be true' do
    a = fast_create(TextileArticle)
    assert a.notifiable?
  end

  should 'notify activity on create' do
    ActionTracker::Record.delete_all
    TextileArticle.create! :name => 'test', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
  end

  should 'notify activity on update' do
    ActionTracker::Record.delete_all
    a = TextileArticle.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
    a.name = 'foo'
    a.save!
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify activity on destroy' do
    ActionTracker::Record.delete_all
    a = TextileArticle.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
    a.destroy
    assert_equal 2, ActionTracker::Record.count
  end

end
