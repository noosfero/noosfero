file = Rails.root.join('config', 'noosfero.yml')
NOOSFERO_CONF = File.exists?(file) ? YAML.load_file(file)[Rails.env] || {} : {}
