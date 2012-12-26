source :rubygems
gem 'cucumber'
# TODO needs a rebuild diff-lcs wrt wheezy

gem 'rspec'
# gem 'rspec-rails', '1.2.9' # FIXME package this

# FIXME list here all actual dependencies (i.e. the ones in debian/control),
# with their GEM names (not the Debian package names)

gem 'rails'

def program(name)
  unless system("which #{name} > /dev/null")
    puts "W: Program #{name} is needed, but was not found in your PATH"
  end
end

program 'java'
program 'firefox'
