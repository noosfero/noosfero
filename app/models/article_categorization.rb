class ArticleCategorization < ActiveRecord::Base
  set_table_name :articles_categories
  belongs_to :article
  belongs_to :category
end
