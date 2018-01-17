Rails.application.configure do
  config.assets.precompile += %w[serviceworker.js manifest.json]

  config.serviceworker.icon_sizes = ["48", "76", "120", "180", "512"]

  config.serviceworker.routes.draw do
    # map to assets implicitly
    match "/serviceworker.js"
    match "/manifest.json"
  end
end
