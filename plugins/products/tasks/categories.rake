require 'yaml'
categories_file = 'categories.yml'
categories_path = [
  Rails.root, "plugins/products/tasks/#{categories_file}"
].join('/')

namespace :noosfero do
  namespace :plugin do
    namespace :products do
      desc "Create sample categories for products plugin"
      task :sample_categories => :environment do
        begin
          categories = YAML.load_file(categories_path)['categories']
          categories.each do |categorie|
              ProductsPlugin::ProductCategory.create({
                name: categorie, environment: Environment.default
              })
          end
        rescue SystemCallError
          p "Could not load #{categories_file}"
          p "Searched path: #{categories_path}"
        end
      end
    end
  end
end
