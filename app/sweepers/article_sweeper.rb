class ArticleSweeper < ActiveRecord::Observer
  observe :article

  def after_save(article)
    expire_caches(article)
  end

  def after_destroy(article)
    expire_caches(article)
  end

protected

  def expire_caches(article)
    article.hierarchy.each {|a| expire_fragment(/#{a.cache_key}/) }
    blocks = article.profile.blocks.select{|b|[RecentDocumentsBlock, BlogArchivesBlock].any?{|c| b.kind_of?(c)}}
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
  end

  def expire_fragment(*args)
    ActionController::Base.new().expire_fragment(*args)
  end

  def expire_timeout_fragment(*args)
    ActionController::Base.new().expire_timeout_fragment(*args)
  end
end
