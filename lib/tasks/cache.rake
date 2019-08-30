namespace :cache do
  task private_files: :environment do
    require "sdbm"

    hash = {}
    UploadedFile.where("access > #{Entitlement::Levels.levels[:visitors]}").find_each do |uploaded_file|
      hash[uploaded_file.public_filename] = uploaded_file.full_path
    end

    begin
      dbm = SDBM.open(UploadedFile::DBM_PRIVATE_FILE)
      dbm.update(hash)
      dbm.close
    rescue Exception => exception
      puts "[E] Could not generate private files dbm file!"
      puts exception.message
    end
  end
end
