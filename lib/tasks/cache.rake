namespace :cache do
  task :private_files => :environment do
    require 'sdbm'

    hash = {}
    UploadedFile.where(:published => false).find_each do |uploaded_file|
      hash[uploaded_file.public_filename] = uploaded_file.full_path
    end

    dbm = SDBM.open(UploadedFile::DBM_PRIVATE_FILE)
    dbm.update(hash)
    dbm.close
  end
end
