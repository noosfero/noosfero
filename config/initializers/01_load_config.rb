file = "#{RAILS_ROOT}/config/noosfero.yml"
NOOSFERO_CONF = File.exists?(file) ? YAML.load_file(file)[RAILS_ENV] || {} : {}
