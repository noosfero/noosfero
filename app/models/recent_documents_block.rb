class RecentDocumentsBlock < Block

  def self.description
    _('Display the last content produced in the context where the block is available.')
  end

  def self.short_description
    _('Show last updates')
  end

  def self.pretty_name
    _('Recent Content')
  end

  def default_title
    _('Recent content')
  end

  def help
    _('This block lists your content most recently updated.')
  end

  settings_items :limit, :type => :integer, :default => 5

  def docs
    docs = owner.articles.relevant_as_recent.more_recent.limit(limit || get_limit)
    if owner.is_a? Environment
      docs = docs.where.not(type: 'LinkArticle')
    end
    docs.limit(limit || get_limit)
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end

  def api_content(params = {})
    { articles: Api::Entities::ArticleBase.represent(docs) }.as_json
  end

  def display_api_content_by_default?
    false
  end
end
