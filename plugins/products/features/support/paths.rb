module NavigationHelpers
  module ProductsPlugin
    def path_to page_name
      case page_name
      when /^(.*)'s products page$/
        '/catalog/%s' % $1
      else
        super
      end
    end
  end

  prepend ProductsPlugin
end

