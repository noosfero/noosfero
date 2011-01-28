if File.writable?(Rails.root)
  misplaced_directories = Dir.glob(Rails.root + '/public/images/[0-9]*')
  unless misplaced_directories.empty?
    new_location = Rails.root + '/public/image_uploads'
    if !File.exists?(new_location)
      FileUtils.mkdir(new_location)
    end
    misplaced_directories.each do |path|
      FileUtils.mv(path, new_location)
    end
  end
end
