require_relative "../test_helper"

class PluginsHelperTest < ActionView::TestCase

  def setup
    @environment = Environment.default
    @plugins = mock
  end

  attr_accessor :environment, :plugins

  should 'plugins_toolbar_actions_for_article return an array if the plugin return a single hash' do
    hash = {:title => 'some title', :url => 'some_url', :icon => 'some icon'}
    plugins.expects(:dispatch).with(:article_extra_toolbar_buttons, nil).returns(hash)
    assert_equal [hash], plugins_toolbar_actions_for_article(nil)
  end

  should 'plugins_toolbar_actions_for_article return an empty array if an array is passed as parameter' do
    plugins.expects(:dispatch).with(:article_extra_toolbar_buttons, nil).returns([])
    assert_equal [], plugins_toolbar_actions_for_article(nil)
  end

  should 'plugins_toolbar_actions_for_article throw raise if no title is passed as parameter' do
    plugins.expects(:dispatch).with(:article_extra_toolbar_buttons, nil).returns({:url => 'some_url', :icon => 'some icon'})

    assert_raise(RuntimeError) do
      plugins_toolbar_actions_for_article(nil)
    end
  end

  should 'plugins_toolbar_actions_for_article throw raise if no icon is passed as parameter' do
    plugins.expects(:dispatch).with(:article_extra_toolbar_buttons, nil).returns({:title => 'some title', :url => 'some_url'})

    assert_raise(RuntimeError) do
      plugins_toolbar_actions_for_article(nil)
    end
  end

  should 'plugins_toolbar_actions_for_article throw raise if no url is passed as parameter' do
    plugins.expects(:dispatch).with(:article_extra_toolbar_buttons, nil).returns({:title => 'some title', :icon => 'some icon'})

    assert_raise(RuntimeError) do
      plugins_toolbar_actions_for_article(nil)
    end
  end

end
