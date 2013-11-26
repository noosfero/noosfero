class AntiSpamPlugin::SuggestArticleWrapper < AntiSpamPlugin::Wrapper
  alias_attribute :author, :name
  alias_attribute :author_email, :email
  alias_attribute :user_ip, :ip_address
  alias_attribute :content, :article_body

  def self.wraps?(object)
    object.kind_of?(SuggestArticle)
  end
end
