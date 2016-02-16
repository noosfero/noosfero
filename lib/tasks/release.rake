# encoding: UTF-8

$version = Noosfero::VERSION

namespace :noosfero do

  def pendencies_on_authors
    sh "git status | grep 'AUTHORS.md' > /dev/null" do |ok, res|
      return {:ok => !ok, :res => res}
    end
  end

  def pendencies_on_repo
    sh "git status | grep 'nothing.*commit' > /dev/null" do |ok, res|
      return {:ok => ok, :res => res}
    end
  end

  def pendencies_on_public_errors
    sh "git status | grep -e '500.html' -e '503.html' > /dev/null" do |ok, res|
      return {:ok => !ok, :res => res}
    end
  end

  def commit_changes(files, commit_message)
    files = files.join(' ')
    puts "\nThere are changes in the following files:"
    sh "git diff #{files}"
    if confirm('Do you want to commit these changes')
      sh "git add #{files}"
      sh "git commit -m '#{commit_message}'"
    else
      sh "git checkout #{files}"
      abort 'There are changes to be commited. Reverting changes and exiting...'
    end
  end

  desc 'checks if there are uncommitted changes in the repo'
  task :check_repo do
    if !pendencies_on_repo[:ok]
      raise "******** There are uncommited changes in the repository, cannot continue"
    end
  end

  desc 'checks if there is already a tag for the current version'
  task :check_tag do
    sh "git tag | grep '^#{$version}$' >/dev/null" do |ok, res|
      if ok
        raise "******** There is already a tag for version #{$version}, cannot continue"
      end
    end
    puts "Not found tag for version #{$version}, we can go on."
  end

  AUTHORS_HEADER = <<EOF
This list is automatically generated at release time. Please do not change it.

If you are not listed here, but should be, please write to the noosfero mailing
list: http://listas.softwarelivre.org/cgi-bin/mailman/listinfo/noosfero-dev
(this list requires subscription to post, but since you are an author of
noosfero, that's not a problem).

Developers
==========

EOF
  AUTHORS_FOOTER = <<EOF

Ideas, specifications and incentive
===================================
Daniel Tygel <dtygel@fbes.org.br>
Guilherme Rocha <guilherme@gf7.com.br>
Raphael Rousseau <raph@r4f.org>
Théo Bondolfi <move@cooperation.net>
Vicente Aguiar <vicenteaguiar@colivre.coop.br>

Arts
===================================
Nara Oliveira <narananet@gmail.com>
EOF

  desc 'updates the authors file'
  task :authors do
    begin
      File.open("AUTHORS.md", 'w') do |output|
        output.puts AUTHORS_HEADER
        output.puts `./script/authors`
        output.puts AUTHORS_FOOTER
      end
      commit_changes(['AUTHORS.md'], 'Updating authors file') if !pendencies_on_authors[:ok]
    rescue Exception => e
      rm_f 'AUTHORS'
      raise e
    end
  end

  def ask(message, default = nil, default_message = nil, symbol = ':')
    default_choice = default ? " [#{default_message || default}]#{symbol} " : "#{symbol} "
    print message + default_choice
    answer = STDIN.gets.chomp
    answer.blank? && default.present? ? default : answer
  end

  def confirm(message, default=true)
    default_message = default ? 'Y/n' : 'y/N'
    default_value = default ? 'y' : 'n'
    choice = nil
    while choice.nil?
      answer = ask(message, default_value, default_message, '?')
      if answer.blank?
        choice = default
      elsif ['y', 'yes'].include?(answer.downcase)
        choice = true
      elsif ['n', 'no'].include?(answer.downcase)
        choice = false
      end
    end
    choice
  end

  desc "uploads the packages to the repository"
  task :upload_packages, :target do |t, args|
    target = args[:target] || 'stable'
    source = Dir['pkg/noosfero-*.tar.gz'].first
    sh "gpg --detach-sign #{source}"
    sh "sha256sum #{source} > #{source}.sha256sum"
    sh "rsync -avp #{source}* download.noosfero.org:repos/source/"
    sh "dput --unchecked noosfero-#{target} #{Dir['pkg/*.changes'].first}"
  end

  desc 'sets the new version on apropriate files'
  task :set_version, :target do |t, args|
    next if File.exist?("tmp/pending-release")
    target = args[:target]

    new_version = $version.dup

    if target =~ /-test$/
      if new_version =~ /~rc\d+/
        new_version.sub!(/\~rc([0-9]+).*/) { "~rc#{$1.to_i + 1}" }
      else
        new_version += '~rc1'
      end
    else
      if new_version =~ /~rc\d+.*/
        new_version.sub!(/~rc[0-9]+.*/, '')
      else
        components = new_version.split('.').map(&:to_i)
        if components.size < 3
          components << 1
        else
          components[-1] += 1
        end
        new_version = components.join('.')
      end
    end

    puts "Current version: #{$version}"
    new_version = ask("Version to release", new_version)
    release_message = ask("Release message")

    sh 'git checkout debian/changelog lib/noosfero/version.rb'
    sh "sed -i \"s/VERSION = '[^']*'/VERSION = '#{new_version}'/\" lib/noosfero/version.rb"
    ENV['DEBFULLNAME'] ||= `git config user.name`.strip
    ENV['DEBEMAIL'] ||= `git config user.email`.strip
    distribution = `dpkg-parsechangelog | sed '/Distribution:/!d; s/^.*:\s*//'`.strip
    sh "dch --newversion #{new_version} --distribution #{distribution} --force-distribution '#{release_message}'"

    sh 'git diff --color debian/changelog lib/noosfero/version.rb'
    if confirm("Commit version bump to #{new_version} on #{target} distribution")
      sh 'git add debian/changelog lib/noosfero/version.rb'
      sh "git commit -m 'Bumping version #{new_version}'"
      sh "touch tmp/pending-release"
    else
      sh 'git checkout debian/changelog lib/noosfero/version.rb'
      abort 'Version update not confirmed. Reverting changes and exiting...'
    end

    $version = new_version
  end

  task :check_release_deps do
    missing = false
    {
      dput: :dput,
      dch: :devscripts,
      git: :git,
    }.each do |program, package|
      if ! system("which #{program} >/dev/null 2>&1")
        puts "Program #{program} missing, install the package #{package}"
        missing = true
      end
    end
    abort if missing
  end

  task :tag do
    sh "git tag -s -m 'Noosfero #{$version}' #{$version.gsub('~','-')}"
  end

  task :pushtag do
    sh "git push origin #{$version.gsub('~','-')}"
  end

  desc 'prepares a release tarball'
  task :release, :target do |t, args|
    target = args[:target]
    if ! target
      abort "Usage: rake noosfero:release[TARGET]"
    end

    puts "==> Checking required packages"
    Rake::Task['noosfero:check_release_deps'].invoke

    puts "==> Updating authors..."
    Rake::Task['noosfero:authors'].invoke

    puts "==> Checking translations..."
    Rake::Task['noosfero:error-pages:translate'].invoke
    if !pendencies_on_public_errors[:ok]
      commit_changes(['public/500.html', 'public/503.html'], 'Updating public error pages')
    end

    Rake::Task['noosfero:set_version'].invoke(target)

    puts "==> Checking tags..."
    Rake::Task['noosfero:check_tag'].invoke

    puts "==> Checking repository..."
    Rake::Task['noosfero:check_repo'].invoke

    puts "==> Preparing debian packages..."
    Rake::Task['noosfero:debian_packages'].invoke

    if confirm("Create tag for version #{$version}")
      Rake::Task['noosfero:tag'].invoke
      if confirm('Push new version tag')
        puts "==> Uploading tags..."
        Rake::Task['noosfero:pushtag'].invoke
      end
    end

    if confirm('Upload the packages')
      puts "==> Uploading debian packages..."
      Rake::Task['noosfero:upload_packages'].invoke(target)
    else
      puts "I: please upload the package manually later by running"
      puts "I: $ rake noosfero:upload_packages"
    end

    rm_f "tmp/pending-release"
  end

  desc "finishes the release"
  task 'release:finish', :target do |t, args|
    target = args[:target]
    unless target
      abort "E: usage: rake noosfero:release:finish[TARGET]"
    end
    Rake::Task['noosfero:upload_packages'].invoke(target)
    Rake::Task['noosfero:tag'].invoke
    Rake::Task['noosfero:pushtag'].invoke
  end

  desc 'Build Debian packages'
  task :debian_packages => :package do
    target = "pkg/noosfero-#{$version}"

    # base pre-config
    mkdir "#{target}/tmp"
    cp "#{target}/config/database.yml.sqlite3", "#{target}/config/database.yml"

    sh "cd #{target} && dpkg-buildpackage -us -uc -b"
  end

  desc "Build Debian packages (shorcut)"
  task :deb => :debian_packages

  desc 'Build Debian snapshot packages (for local testing)'
  task 'deb:snapshot' => :package do
    target = "pkg/noosfero-#{$version}"
    Dir.chdir target do
      sh 'dch', '-v', $version.gsub('-', '.'), 'snapshot'
    end
    Rake::Task['noosfero:deb'].invoke
  end

  desc 'Test Debian package'
  task 'debian:test' => :debian_packages do
    Dir.chdir 'pkg' do
      rm_rf "noosfero-#{$version}"
      sh 'apt-ftparchive packages . > Packages'
      sh 'apt-ftparchive release . > Release'
    end
  end

end
