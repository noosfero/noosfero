module ProductsPlugin
  class ProductCategory < ::Category

    ##
    # Keep compatibility with previous core name
    #
    def self.sti_name
      'ProductCategory'
    end

    has_many :products
    has_many :inputs

    attr_accessible :name, :parent, :environment

    scope :unique, -> { select 'DISTINCT ON (path) categories.*' }
    scope :by_enterprise, -> enterprise {
      distinct.joins(:products).
      where('products.profile_id = ?', enterprise.id)
    }
    scope :by_environment, -> environment {
      where 'environment_id = ?', environment.id
    }

    def all_products
      Product.where(product_category_id: (all_children << self).map(&:id))
    end

    def recent_products(limit = 10)
      self.products.reorder('created_at DESC, id DESC').paginate(page: 1, per_page: limit)
    end

    def self.menu_categories(top_category, env)
      top_category ? top_category.children : top_level_for(env).select{|c|c.kind_of?(ProductCategory)}
    end

  end
end
