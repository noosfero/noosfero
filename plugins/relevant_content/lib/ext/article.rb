require_dependency 'article'

class Article

  named_scope :relevant_content, :conditions => ["(articles.type != 'UploadedFile' and articles.type != 'Blog' and articles.type != 'RssFeed') OR articles.type is NULL"]

  def self.most_accessed(owner, limit = nil)
    if owner.kind_of?(Environment)
      result = Article.relevant_content.find(
        :all,
        :order => 'hits desc',
        :limit => limit,
        :conditions => ["hits > 0"]
      )
      result.paginate({:page => 1, :per_page => limit})
    else
      #Owner is a profile
      result = Article.relevant_content.find(
        :all,
        :order => 'hits desc',
        :limit => limit,
        :conditions => ["profile_id = ? and hits > 0", owner.id]
      )
      result.paginate({:page => 1, :per_page => limit})
    end
  end

  def self.most_commented_relevant_content(owner, limit)

    if owner.kind_of?(Environment)
      result = Article.relevant_content.find(
        :all,
        :order => 'comments_count desc',
        :limit => limit,
        :conditions => ["comments_count > 0"]
      )
      result.paginate({:page => 1, :per_page => limit})
    else
      #Owner is a profile
      result = Article.relevant_content.find(
        :all,
        :order => 'comments_count desc',
        :limit => limit,
        :conditions => ["profile_id = ? and comments_count > 0", owner.id]
      )
      result.paginate({:page => 1, :per_page => limit})
    end
  end

  def self.articles_columns
    Article.column_names.map {|c| "articles.#{c}"} .join(",")
  end

  def self.more_positive_votes(owner, limit = nil)
    if owner.kind_of?(Environment)
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'sum(vote) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :having => ['sum(vote) > 0'],
        :conditions => {'votes.voteable_type' => 'Article'},
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id'
      )
      result.paginate({:page => 1, :per_page => limit})
    else
      #Owner is a profile
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'sum(vote) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :having => ['sum(vote) > 0'],
        :conditions => ["profile_id = ? and votes.voteable_type = ? ", owner.id, 'Article']
      )
      result.paginate({:page => 1, :per_page => limit})
    end
  end

  def self.more_negative_votes(owner, limit = nil)
    if owner.kind_of?(Environment)
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'sum(vote) asc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :having => ['sum(vote) < 0'],
        :conditions => {'votes.voteable_type' => 'Article'},
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id'
      )
       result.paginate({:page => 1, :per_page => limit})
    else
      #Owner is a profile
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'sum(vote) asc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :having => ['sum(vote) < 0'],
        :conditions => ["profile_id = ? and votes.voteable_type = 'Article' ", owner.id]
      )
      result.paginate({:page => 1, :per_page => limit})
    end
  end

  def self.most_liked(owner, limit = nil)
    if owner.kind_of?(Environment)
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :conditions => ["votes.voteable_type = 'Article' and vote > 0"]
      )
      result.paginate({:page => 1, :per_page => limit})
    else
      #Owner is a profile
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :conditions => ["votes.voteable_type = 'Article' and vote > 0 and profile_id = ? ", owner.id]
      )
      result.paginate({:page => 1, :per_page => limit})
    end
  end

  def self.most_disliked(owner, limit = nil)
    if owner.kind_of?(Environment)
      result = Article.find(
        :all,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :conditions => ["votes.voteable_type = 'Article' and vote < 0"]
      )
       result.paginate({:page => 1, :per_page => limit})
    else
      #Owner is a profile
      result = Article.find(
        :all,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :conditions => ["votes.voteable_type = 'Article' and vote < 0 and profile_id = ? ", owner.id]
      )
      result.paginate({:page => 1, :per_page => limit})
    end
  end

  def self.most_voted(owner, limit = nil)
    if owner.kind_of?(Environment)
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :conditions => ["votes.voteable_type = 'Article'"]
      )
      result.paginate({:page => 1, :per_page => limit})
    else
      #Owner is a profile
      result = Article.find(
        :all,
        :select => articles_columns,
        :order => 'count(voteable_id) desc',
        :group => 'voteable_id, ' + articles_columns,
        :limit => limit,
        :joins => 'INNER JOIN votes ON articles.id = votes.voteable_id',
        :conditions => ["votes.voteable_type = 'Article' and profile_id = ? ", owner.id]
      )
      result.paginate({:page => 1, :per_page => limit})
    end
  end




end