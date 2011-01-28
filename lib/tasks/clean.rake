task :clean => 'noosfero:clean'

namespace :noosfero do
  task :clean do

    if Rails.env == 'production'
      raise 'You should NOT run this in production mode!'
    end

    clean_patterns = %w[
      db/*.db
      public/javascripts/cache*.js
      public/stylesheets/cache*.css
      public/designs/themes/default
      public/designs/icons/default
      public/articles/
      public/image_uploads/
      public/thumbnails/
      locale/
    ]
    clean_patterns << Dir.glob('public/designs/themes/*').select { |f| File.symlink?(f) }

    clean_patterns.each do |pattern|
      list = Dir.glob(pattern)
      rm_rf list unless list.empty?
    end
  end
end
