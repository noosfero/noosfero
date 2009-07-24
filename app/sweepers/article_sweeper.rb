class ArticleSweeper < ActiveRecord::Observer
  include SweeperHelper
  observe :article

  def after_save(article)
    expire_caches(article)
  end

  def after_destroy(article)
    expire_caches(article)
  end

protected

  def expire_caches(article)
    article.hierarchy.each {|a| expire_fragment(a.cache_key) }
    blocks = (article.profile.blocks + article.profile.environment.blocks).select{|b|[RecentDocumentsBlock, BlogArchivesBlock].any?{|c| b.kind_of?(c)}}
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
    env = article.profile.environment
    if env.portal_community == article.profile
      expire_fragment("home_page_news_#{env.id}")
    end
  end

end
