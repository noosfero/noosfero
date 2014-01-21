source "https://rubygems.org"
gem 'rails'
gem 'fast_gettext'
gem 'acts-as-taggable-on'
gem 'prototype-rails'
gem 'prototype_legacy_helper', '0.0.0', :git => 'http://git.github.com/rails/prototype_legacy_helper.git'

# TODO needs a rebuild diff-lcs wrt wheezy

# FIXME list here all actual dependencies (i.e. the ones in debian/control),
# with their GEM names (not the Debian package names)

group :test do
  #gem 'rspec'
  #gem 'rspec-rails'
end

group :cucumber do
  gem 'rake'
  # TODO gem 'cucumber-rails'
  # TODO gem 'capybara'
  # gem 'cucumber'
  # TODO gem 'database_cleaner'
end

def program(name)
  unless system("which #{name} > /dev/null")
    puts "W: Program #{name} is needed, but was not found in your PATH"
  end
end

program 'java'
program 'firefox'
