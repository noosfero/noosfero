class ArticleFollower < ApplicationRecord

  attr_accessible :article_id, :person_id
  belongs_to :article, :counter_cache => :followers_count
  belongs_to :person

end
