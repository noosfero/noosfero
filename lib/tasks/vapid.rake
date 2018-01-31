require 'optparse'

namespace :vapid do
  namespace :keys do
    CONF_FILE = Rails.root.join('config', 'vapid.yml')

    task :check do
      exit (check_keys ? 0 : 1)
    end

    task :generate do
      opts = {}
      op = OptionParser.new
      op.on("-f", "--force", "Override existing keys") { |f| opts[:force] = f }
      op.parse!(op.order!(ARGV) {})

      if !opts[:force] && check_keys
        puts "There is a valid pair of keys in #{CONF_FILE}"
        print "Are you sure you want to generate a new one? (y/n): "
        answer = STDIN.gets.chomp
        exit 0 unless answer.downcase == 'y'
      end
      generate_keys!
    end

    def check_keys
      if File.file?(CONF_FILE)
        data = YAML::load_file(CONF_FILE)
        return data['private_key'].present? && data['public_key'].present?
      else
        return false
      end
    end

    def generate_keys!
      keys = Webpush.generate_key
      puts "Saving a new VAPID key pair in #{CONF_FILE}..."
      File.write(CONF_FILE, {
        'private_key' => keys.private_key,
        'public_key' => keys.public_key
      }.to_yaml)
    end
  end
end
