task :load_backup_config do
  $config = YAML.load_file('config/database.yml')
end

task :check_backup_support => :load_backup_config do
  if $config['production']['adapter'] != 'postgresql'
    fail("Only PostgreSQL is supported for backups at the moment")
  end
end

backup_dirs = [
  'public/image_uploads',
  'public/articles',
  'public/thumbnails',
  'public/user_themes',
]

desc "Creates a backup of the database and uploaded files"
task :backup => :check_backup_support do
  dirs = backup_dirs.select { |d| File.exists?(d) }

  backup_name = Time.now.strftime('%Y-%m-%d-%R')
  backup_file = File.join('tmp/backup', backup_name) + '.tar.gz'
  mkdir_p 'tmp/backup'
  dump = File.join('tmp/backup', backup_name) + '.sql'

  database = $config['production']['database']
  host = $config['production']['host']
  sh "pg_dump -h #{host} #{database} > #{dump}"

  sh 'tar', 'chaf', backup_file, dump, *dirs
  rm_f dump

  puts "****************************************************"
  puts "Backup in #{backup_file} !"
  puts
  puts "To restore, use:"
  puts "$ rake restore BACKUP=#{backup_file}"
  puts "****************************************************"
end

def invalid_backup!(message, items=[])
  puts "E: #{message}"
  items.each do |i|
    puts "E: - #{i}"
  end
  puts "E: Is this a backup archive created by Noosfero with \`rake backup\`?"
  exit 1
end

desc "Restores a backup created previousy with \`rake backup\`"
task :restore => :check_backup_support do
  backup = ENV["BACKUP"]
  unless backup
    puts "usage: rake restore BACKUP=/path/to/backup"
    exit 1
  end

  files = `tar taf #{backup}`.split

  # validate files in the backup
  invalid_files = []
  files.each do |f|
    if f !~ /tmp\/backup\// && (backup_dirs.none? { |d| f =~ /^#{d}\// })
      invalid_files << f
    end
  end
  if invalid_files.size > 0
    invalid_backup!("Invalid files found in the backup archive", invalid_files)
  end

  # find database dump in the archive
  dumps = files.select do |f|
    File.dirname(f) == 'tmp/backup' && f =~ /\.sql$/
  end
  if dumps.size == 0
    invalid_backup!("Could not find a database dump in the archive.")
  elsif dumps.size > 1
    invalid_backup!("Multiple database dumps found in the archive:", dumps)
  end
  dump = dumps.first

  database = $config['production']['database']
  username = $config['production']['username']
  host = $config['production']['host']

  puts "WARNING: backups should be restored to an empty database, otherwise"
  puts "data from the backup may not be loaded properly."
  puts
  puts 'You can remove the existing database and create a new one with:'
  puts
  puts "$ sudo -u postgres dropdb -h #{host} #{database}"
  puts "$ sudo -u postgres createdb -h #{host} #{database} --owner #{username}"
  puts
  print "Are you sure you want to continue (y/N)? "
  response = $stdin.gets.strip
  unless ['y', 'yes'].include?(response.downcase)
    puts "*** ABORTED."
    exit 1
  end

  sh 'tar', 'xaf', backup
  sh "rails dbconsole production < #{dump}"
  rm_f dump

  puts "****************************************************"
  puts "Backup restored!"
  puts "****************************************************"
end
