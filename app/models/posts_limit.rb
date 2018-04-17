module PostsLimit
  module ClassMethods
    def posts_per_page_limit
      15
    end

    def posts_per_page_options
      [5, 10, 15]
    end
  end

  def self.included(klass)
    klass.send(:extend, PostsLimit::ClassMethods)
    klass.class_eval do
      def posts_per_page_with_limit
        [self.class.posts_per_page_limit, posts_per_page_without_limit].min
      end
      alias_method :posts_per_page_without_limit, :posts_per_page
      alias_method :posts_per_page, :posts_per_page_with_limit
    end
  end
end
