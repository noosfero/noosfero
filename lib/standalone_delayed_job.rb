module Rails
  extend self

  def root
    File.dirname(File.expand_path('..', __FILE__))
  end

  def logger
    @logger ||= Logger.new $stdout
  end
end

require 'pg'
require 'delayed_job'
require 'delayed_job_active_record'
require 'active_record'

require 'yaml'
require 'erb'
ENV["RAILS_ENV"] ||= 'development'
yaml = Pathname.new(Dir.glob(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml{,.erb}')).last)
ActiveRecord::Base.configurations = YAML.load(ERB.new(yaml.read).result) || {}

Delayed::Worker.backend = :active_record
ActiveRecord::Base.establish_connection
