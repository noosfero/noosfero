class AntiSpamPlugin::SuggestArticleWrapper < Struct.new(:suggest_article)

  delegate :name, :email, :article_body, :ip_address, :user_agent, :referrer, :to => :suggest_article

  include Rakismet::Model

  alias :author :name
  alias :author_email :email
  alias :user_ip :ip_address
  alias :content :article_body

end
