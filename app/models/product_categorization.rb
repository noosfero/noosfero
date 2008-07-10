class ProductCategorization < ActiveRecord::Base
  belongs_to :product_category, :foreign_key => 'category_id'
  belongs_to :product

  extend Categorization

  class << self
    alias :add_category_to_product :add_category_to_object
    def object_id_column
      :product_id
    end
  end
end
