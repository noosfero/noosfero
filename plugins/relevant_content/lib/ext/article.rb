require_dependency 'article'

class Article

  scope :relevant_content, :conditions => ["articles.published = true and (articles.type != 'UploadedFile' and articles.type != 'Blog' and articles.type != 'RssFeed') OR articles.type is NULL"]

  def self.articles_columns
    Article.column_names.map {|c| "articles.#{c}"} .join(",")
  end

  def self.most_accessed(owner, limit = nil)
    conditions = owner.kind_of?(Environment) ?  ["hits > 0"] : ["profile_id = ? and hits > 0", owner.id]
    result = Article.relevant_content.find(
      :all,
      :order => 'hits desc',
      :limit => limit,
      :conditions => conditions)
    result.paginate({:page => 1, :per_page => limit})
  end

  def self.most_commented_relevant_content(owner, limit)
      conditions = owner.kind_of?(Environment) ? ["comments_count > 0"] : ["profile_id = ? and comments_count > 0", owner.id]
      result = Article.relevant_content.find(
        :all,
        :order => 'comments_count desc',
        :limit => limit,
        :conditions => conditions)
      result.paginate({:page => 1, :per_page => limit})
  end

  def self.more_positive_votes(owner, limit = nil)
      conditions = owner.kind_of?(Environment) ? {'votes.voteable_type' => 'Article'} : ["profile_id = ? and votes.voteable_type = ? ", owner.id, 'Article']
      result = Article.relevant_content.find(
        :all,
        :order => 'sum(vote) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :having => ['sum(vote) > 0'],
        :conditions => conditions,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id')
      result.paginate({:page => 1, :per_page => limit})
  end

  def self.more_negative_votes(owner, limit = nil)
      conditions = owner.kind_of?(Environment) ? {'votes.voteable_type' => 'Article'} : ["profile_id = ? and votes.voteable_type = 'Article' ", owner.id]
      result = Article.relevant_content.find(
        :all,
        :order => 'sum(vote) asc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :having => ['sum(vote) < 0'],
        :conditions => conditions,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id'
      )
      result.paginate({:page => 1, :per_page => limit})
  end

  def self.most_liked(owner, limit = nil)
      conditions = owner.kind_of?(Environment) ? ["votes.voteable_type = 'Article' and vote > 0"] : ["votes.voteable_type = 'Article' and vote > 0 and profile_id = ? ", owner.id]
      result = Article.relevant_content.find(
        :all,
        :select => articles_columns,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :conditions => conditions,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id')
      result.paginate({:page => 1, :per_page => limit})
  end

  def self.most_disliked(owner, limit = nil)
      conditions = owner.kind_of?(Environment) ? ["votes.voteable_type = 'Article' and vote < 0"] : ["votes.voteable_type = 'Article' and vote < 0 and profile_id = ? ", owner.id]
      result = Article.relevant_content.find(
        :all,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :conditions => conditions,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id')
       result.paginate({:page => 1, :per_page => limit})
  end

  def self.most_voted(owner, limit = nil)
    conditions = owner.kind_of?(Environment) ? ["votes.voteable_type = 'Article'"] : ["votes.voteable_type = 'Article' and profile_id = ? ", owner.id]
      result = Article.relevant_content.find(
        :all,
        :select => articles_columns,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :conditions => conditions,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id')
      result.paginate({:page => 1, :per_page => limit})
  end
end
