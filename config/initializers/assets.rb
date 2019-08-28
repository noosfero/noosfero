# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# We don't want the default of everything that isn't js or css, because it pulls too many things in
Rails.application.config.assets.precompile.shift

# Explicitly register the extensions we are interested in compiling
Rails.application.config.assets.precompile.push(Proc.new do |path|
  File.extname(path).in? [
#    '.html', '.erb', '.haml',                 # Templates
    '.png',  '.gif', '.jpg', '.jpeg',         # Images
    '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
  ]
end)

# Add extra assets
Rails.application.config.assets.precompile += Dir.glob('public/plugins/*/**/*.js').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/javascripts/*').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/javascripts/*/**/*.js').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/designs/icons/*/**/*.js').map{|path| path.gsub('public/', '')}

Rails.application.config.assets.precompile += Dir.glob('public/stylesheets/*/**/*.css').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/stylesheets/*/**/*.scss').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/stylesheets/*').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/plugins/*/*.css').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/plugins/*/**/*.css').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/plugins/*/**/*.scss').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/designs/themes/*/**/*.css').map{|path| path.gsub('public/', '')}
Rails.application.config.assets.precompile += Dir.glob('public/designs/icons/*/**/*.css').map{|path| path.gsub('public/', '')}
