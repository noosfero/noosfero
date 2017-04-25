update = false

unless system 'dpkg -s ruby-pg-search', :out => File::NULL
  system 'sudo apt-get update', :out => File::NULL
  update = true
  unless system 'sudo apt-get install -y ruby-pg-search', :out => File::NULL
    exit $?.exitstatus
  end
end

# TODO Use this code in order to install extensions.
#
# unless system 'dpkg -s postgresql-contrib', :out => File::NULL
#   unless  update
#     system'sudo apt-get update', :out => File::NULL
#   end
#   unless system 'sudo apt-get install -y postgresql-contrib', :out => File::NULL
#     exit $?.exitstatus
#   end
# end
#
#
# require 'yaml'
#
# config = YAML.load_file(File.dirname(__FILE__) + '/' + File.join('..', '..','config', 'database.yml'))
# config.each do |key, value|
#   database_name = value['database']
#   next unless system("psql -lqt | cut -d '|' -f 1 | grep -qw #{database_name}") # Check if database exists
#   system "2>/dev/null 1>&2 sudo -u postgres psql -d #{database_name} -c 'CREATE EXTENSION IF NOT EXISTS unaccent; CREATE EXTENSION IF NOT EXISTS pg_trgm;' "
# end
