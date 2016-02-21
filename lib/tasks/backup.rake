task :load_backup_config do
  db_file = Rails.root.join('config', 'database.yml')
  $config = YAML.load(ERB.new(File.read(db_file)).result)
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
  rails_env = ENV["RAILS_ENV"] || 'production'

  backup_name = Time.now.strftime('%Y-%m-%d-%R')
  backup_file = File.join('tmp/backup', backup_name) + '.tar.gz'
  mkdir_p 'tmp/backup'
  dump = File.join('tmp/backup', backup_name) + '.sql'

  database = $config[rails_env]['database']
  host = $config[rails_env]['host']
  host = host && "-h #{host}" || ""
  sh "pg_dump #{host} #{database} > #{dump}"

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
  rails_env = ENV["RAILS_ENV"] || 'production'
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

  database = $config[rails_env]['database']
  username = $config[rails_env]['username']
  host = $config[rails_env]['host']
  host = host && "-h #{host}" || ""

  puts "WARNING: backups should be restored to an empty database, otherwise"
  puts "data from the backup may not be loaded properly."
  puts
  puts 'You can remove the existing database and create a new one with:'
  puts
  puts "$ sudo -u postgres dropdb #{host} #{database}"
  puts "$ sudo -u postgres createdb #{host} #{database} --owner #{username}"
  puts
  print "Are you sure you want to continue (y/N)? "
  response = $stdin.gets.strip
  unless ['y', 'yes'].include?(response.downcase)
    puts "*** ABORTED."
    exit 1
  end

  sh 'tar', 'xaf', backup
  sh "rails dbconsole #{rails_env} < #{dump}"
  rm_f dump

  puts "****************************************************"
  puts "Backup restored!"
  puts "****************************************************"
end

desc 'Removes emails from database'
task 'restore:remove_emails' => :environment do
  connection = ApplicationRecord.connection
  [
    "UPDATE users SET email = concat('user', id, '@localhost.localdomain')",
    "UPDATE environments SET contact_email = concat('environment', id, '@localhost.localdomain')",
  ].each do |update|
    puts update
    connection.execute(update)
  end

  profiles = connection.execute("select id, data from profiles")
  profiles.each do |profile|
    if profile['data']
      data = YAML.load(profile['data'])
      if data[:contact_email] && data[:contact_email] !~ /@localhost.localdomain$/
        data[:contact_email] = ['profile', profile['id'], '@localhost.localdomain'].join
        sql = Environment.send(:sanitize_sql, [
          "UPDATE profiles SET data = ? WHERE id = ?",
          YAML.dump(data),
          profile['id'],
        ])
        puts sql
        connection.execute(sql)
      end
    end
  end
end
