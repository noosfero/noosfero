class ArticleCategorization < ApplicationRecord
  self.table_name = :articles_categories

  belongs_to :article, optional: true
  belongs_to :category, optional: true

  extend Categorization

  class << self
    alias :add_category_to_article :add_category_to_object
    def object_id_column
      :article_id
    end
  end

end
