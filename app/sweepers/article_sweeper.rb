class ArticleSweeper < ActiveRecord::Observer
  include SweeperHelper
  observe :article

  def after_save(article)
    expire_caches(article)
  end

  def after_destroy(article)
    expire_caches(article)
  end

  def before_update(article)
    if article.parent_id_change
      Article.find(article.parent_id_was).touch if article.parent_id_was
    end
  end

protected

  def expire_caches(article)
    return if !article.environment
    article.hierarchy(true).each { |a| a.touch if a != article }
    blocks = article.profile.blocks
    blocks += article.profile.environment.blocks if article.profile.environment
    blocks = blocks.select{|b|[RecentDocumentsBlock, BlogArchivesBlock].any?{|c| b.kind_of?(c)}}
    BlockSweeper.expire_blocks(blocks)
    env = article.profile.environment
    if env && (env.portal_community == article.profile)
      article.environment.locales.keys.each do |locale|
        expire_fragment(env.portal_news_cache_key(locale))
      end
    end
  end

end
