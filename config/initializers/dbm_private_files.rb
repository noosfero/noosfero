path = File.join(Rails.root,'cache')
FileUtils.mkdir(path) unless File.exists?(path)
