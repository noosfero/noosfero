file = Rails.root.join('config', 'vapid.yml')
VAPID_KEYS = File.file?(file) ? YAML.load_file(file) : {}
