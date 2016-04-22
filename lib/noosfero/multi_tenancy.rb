module Noosfero
  class MultiTenancy

    def self.mapping
      @mapping ||= self.load_map
    end

    def self.on?
      !self.mapping.blank? || self.is_hosted_environment?
    end

    def self.db_by_host=(host)
      if host != @db_by_host
        @db_by_host = host
        ApplicationRecord.connection.schema_search_path = self.mapping[host]
      end
    end

    def self.setup!(host)
      if Noosfero::MultiTenancy.on? and ApplicationRecord.postgresql?
        Noosfero::MultiTenancy.db_by_host = host
      end
    end

    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)
        Noosfero::MultiTenancy.setup!(request.host)
        @app.call(env)
      end
    end

    private

    def self.load_map
      db_file = Rails.root.join('config', 'database.yml')
      db_config = YAML.load(ERB.new(File.read(db_file)).result)
      map = { }
      db_config.each do |env, attr|
        next unless env.match(/_#{Rails.env}$/) and attr['adapter'] =~ /^postgresql$/i
        attr['domains'].each { |d| map[d] = attr['schema_search_path'] }
      end
      map
    end

    def self.is_hosted_environment?
      db_file = Rails.root.join('config', 'database.yml')
      db_config = YAML.load(ERB.new(File.read(db_file)).result)
      db_config.select{ |env, attr| Rails.env.to_s.match(/_#{env}$/) }.any?
    end

  end
end
