require 'rake/packagetask'
require 'noosfero'

Rake::PackageTask.new(Noosfero::PROJECT, Noosfero::VERSION) do |p|
  p.need_tar_gz = true

  # application files
  p.package_files.include('app/**/*.{rb,rhtml}')
  p.package_files.include('config/**/*.{rb,sqlite3}')
  p.package_files.include('config/ferret_server.yml')
  p.package_files.include('db/migrate/*.rb')
  p.package_files.include('doc/README_FOR_APP')
  p.package_files.include('lib/**/*.{rake,rb}')
  p.package_files.include('log')
  p.package_files.include('po/*/noosfero.po')
  p.package_files.include('po/noosfero.pot')
  p.package_files.include('public/designs/**/*')
  p.package_files.include('public/dispatch.*')
  p.package_files.include('public/favicon.ico')
  p.package_files.include('public/*.html')
  p.package_files.include('public/images/**/*')
  p.package_files.include('public/javascripts/**/*')
  p.package_files.include('public/robots.txt')
  p.package_files.include('public/stylesheets/**/*')
  p.package_files.include('Rakefile')
  p.package_files.include('script/**/*')
  p.package_files.include('test/**/*.{rb,yml}')
  p.package_files.include('test/fixtures/files/*')
  p.package_files.include('tmp/cache')
  p.package_files.include('tmp/sessions')
  p.package_files.include('tmp/sockets')

  # symbolic links
  p.package_files.include('app/views/profile_design/*.rhtml')
  p.package_files.include('app/views/environment_design/*.rhtml')

  # external resources
  p.package_files.include('vendor/**/*')

  # exclusions
  p.package_files.exclude('coverage/**/*')

end
