class ArticleCategorization < ApplicationRecord
  self.table_name = :articles_categories

  belongs_to :article
  belongs_to :category

  extend Categorization

  class << self
    alias :add_category_to_article :add_category_to_object
    def object_id_column
      :article_id
    end
  end

end
