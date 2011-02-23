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
    article.hierarchy.each do |a|
      if a != article
        a.update_attribute(:updated_at, Time.now)
      end
    end
    blocks = article.profile.blocks
    blocks += article.profile.environment.blocks if article.profile.environment
    blocks = blocks.select{|b|[RecentDocumentsBlock, BlogArchivesBlock].any?{|c| b.kind_of?(c)}}
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
    env = article.profile.environment
    if env && (env.portal_community == article.profile)
      expire_fragment(env.portal_news_cache_key)
    end
  end

end
