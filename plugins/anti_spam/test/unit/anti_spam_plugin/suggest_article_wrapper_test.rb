require 'test_helper'

class AntiSpamPlugin::SuggestArticleWrapperTest < ActiveSupport::TestCase

  def setup
    @suggest_article = SuggestArticle.new(
      :article => {:body=> 'comment body'},
      :name => 'author',
      :email => 'foo@example.com',
      :ip_address => '1.2.3.4',
      :user_agent => 'Some Good Browser (I hope)',
      :referrer => 'http://noosfero.org/'
    )
    @wrapper = AntiSpamPlugin::SuggestArticleWrapper.new(@suggest_article)
  end

  should 'get contents' do
    assert_equal @suggest_article.article[:body], @wrapper.content
  end

  should 'get author name' do
    assert_equal @suggest_article.name, @wrapper.author
  end

  should 'get author email' do
    assert_equal @suggest_article.email, @wrapper.author_email
  end

  should 'get IP address' do
    assert_equal @suggest_article.ip_address, @wrapper.user_ip
  end

  should 'get User-Agent' do
    assert_equal @suggest_article.user_agent, @wrapper.user_agent
  end

  should 'get get Referrer' do
    assert_equal @suggest_article.referrer, @wrapper.referrer
  end

end
