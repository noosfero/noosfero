desc "Creates a backup of the user files stored in public/"
task :backup do
  dirs = Dir.glob('public/images/[0-9][0-9][0-9][0-9]') + ['public/articles', 'public/thumbnails', 'public/user_themes'].select { |d| File.exists?(d) }
  tarball = 'backups/files-' + Time.now.strftime('%Y-%m-%d-%R') + '.tar'

  mkdir_p(File.dirname(tarball))
  sh('tar', 'cf', tarball, *dirs)
end
