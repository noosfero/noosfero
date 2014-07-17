# encoding: UTF-8

namespace :noosfero do

  def pendencies_on_authors
    sh "git status | grep 'AUTHORS' > /dev/null" do |ok, res| 
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

  def version
    require 'noosfero'
    Noosfero::VERSION
  end

  desc 'checks if there is already a tag for the current version'
  task :check_tag do
    sh "git tag | grep '^#{version}$' >/dev/null" do |ok, res|
      if ok
        raise "******** There is already a tag for version #{version}, cannot continue"
      end
    end
    puts "Not found tag for version #{version}, we can go on."
  end

  desc 'checks the version of the Debian package'
  task :check_debian_package do
    debian_version = `dpkg-parsechangelog | grep Version: | cut -d ' ' -f 2`.strip
    unless debian_version =~ /^#{version}/
      puts "Version mismatch: Debian version = #{debian_version}, Noosfero upstream version = #{version}"
      puts "Run `dch -v #{version}` to add a new changelog entry that upgrades the Debian version"
      raise "Version mismatch between noosfero version and debian package version"
    end
  end


  AUTHORS_HEADER = <<EOF
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

  desc 'updates the AUTHORS file'
  task :authors do
    begin
      File.open("AUTHORS", 'w') do |output|
        output.puts AUTHORS_HEADER
        output.puts `git log --pretty=format:'%aN <%aE>' | sort | uniq`
        output.puts AUTHORS_FOOTER
      end
      commit_changes(['AUTHORS'], 'Updating AUTHORS file') if !pendencies_on_authors[:ok]
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
  task :upload_packages, :release_kind do |t, args|
    release_kind = args[:release_kind] || 'stable'
    sh "dput --unchecked #{release_kind} #{Dir['pkg/*.changes'].first}"
  end

  desc 'sets the new version on apropriate files'
  task :set_version, :release_kind do |t, args|
    next if File.exist?("tmp/pending-release")
    release_kind = args[:release_kind] || 'stable'

    if release_kind =~ /test/
      version_question = "Release candidate of which version: "
      if release_kind == 'squeeze-test'
        distribution = 'squeeze-test'
      elsif release_kind == 'wheezy-test'
        distribution = 'wheezy-test'
      end
    else
      version_question = "Version that is being released: "
      distribution = 'unstable'
    end

    version_name = new_version = ask(version_question)

    if release_kind =~ /test/
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      version_name += "~rc#{timestamp}"
    end
    release_message = ask("Release message")

    sh 'git checkout debian/changelog lib/noosfero.rb'
    sh "sed -i \"s/VERSION = '[^']*'/VERSION = '#{version_name}'/\" lib/noosfero.rb"
    sh "dch --newversion #{version_name} --distribution #{distribution} --force-distribution '#{release_message}'"

    sh 'git diff debian/changelog lib/noosfero.rb'
    if confirm("Commit version bump to #{version_name} on #{distribution} distribution")
      sh 'git add debian/changelog lib/noosfero.rb'
      sh "git commit -m 'Bumping version #{version_name}'"
      sh "touch tmp/pending-release"
    else
      sh 'git checkout debian/changelog lib/noosfero.rb'
      abort 'Version update not confirmed. Reverting changes and exiting...'
    end
  end

  desc 'prepares a release tarball'
  task :release, :release_kind do |t, args|
    release_kind = args[:release_kind] || 'stable'

    puts "==> Updating authors..."
    Rake::Task['noosfero:authors'].invoke

    Rake::Task['noosfero:set_version'].invoke(release_kind)

    puts "==> Checking tags..."
    Rake::Task['noosfero:check_tag'].invoke

    puts "==> Checking debian package version..."
    Rake::Task['noosfero:check_debian_package'].invoke

    puts "==> Checking translations..."
    Rake::Task['noosfero:error-pages:translate'].invoke
    if !pendencies_on_public_errors[:ok]
      commit_changes(['public/500.html', 'public/503.html'], 'Updating public error pages')
    end

    puts "==> Checking repository..."
    Rake::Task['noosfero:check_repo'].invoke

    puts "==> Preparing debian packages..."
    Rake::Task['noosfero:debian_packages'].invoke
    if confirm('Do you want to upload the packages')
      puts "==> Uploading debian packages..."
      Rake::Task['noosfero:upload_packages'].invoke(release_kind)
    end

    sh "git tag #{version.gsub('~','-')}"
    push_tags = confirm('Push new version tag')
    if push_tags
      repository = ask('Repository name', 'origin')
      puts "==> Uploading tags..."
      sh "git push #{repository} #{version.gsub('~','-')}"
    end

    sh "rm tmp/pending-release" if Dir["tmp/pending-release"].first.present?

    puts "I: please upload the tarball and Debian packages to the website!"
    puts "I: please push the tag for version #{version} that was just created!" if !push_tags
    puts "I: notify the community about this sparkling new version!"
  end

  desc 'Build Debian packages'
  task :debian_packages => :package do
    target = "pkg/noosfero-#{Noosfero::VERSION}"

    # base pre-config
    mkdir "#{target}/tmp"
    ln_s '../../../vendor/rails', "#{target}/vendor/rails"
    cp "#{target}/config/database.yml.sqlite3", "#{target}/config/database.yml"

    sh "cd #{target} && dpkg-buildpackage -us -uc -b"
  end

  desc "Build Debian packages (shorcut)"
  task :deb => :debian_packages

  desc 'Test Debian package'
  task 'debian:test' => :debian_packages do
    Dir.chdir 'pkg' do
      rm_rf "noosfero-#{Noosfero::VERSION}"
      sh 'apt-ftparchive packages . > Packages'
      sh 'apt-ftparchive release . > Release'
    end
  end

end
