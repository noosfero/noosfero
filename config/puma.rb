require_relative 'dotenv'

RailsRoot      = Dir.pwd
BindPort       = (ENV['BIND_PORT'] || '3000').to_i
Production     = if ENV['RAILS_ENV'] == 'production' then true else false end

Workers        = (ENV['WORKERS'] || '2').to_i
Threads        = (ENV['THREADS'] || '5').to_i
WorkerMaxMem   = (ENV['WORKER_MAX_MEM'] || '512').to_i

DaemonPriority = (ENV['DAEMON_PRIORITY'] || '-5').to_i
WorkerDaemons  = {
  delayed_job: {
    worker_nr: 0,
    run:       -> do
      require 'delayed_job'
      worker = Delayed::Worker.new
      worker.name_prefix = 'puma worker 0'
      worker.start
    end,
  },
  feed_updater: {
    worker_nr: 0,
    run:       -> do
      FeedUpdater.new.run
    end,
  },
}

preload_app!

directory       RailsRoot
pidfile         "#{RailsRoot}/tmp/pids/puma.pid"
bind            "unix://#{RailsRoot}/run/puma.sock" if Production
bind            "tcp://0.0.0.0:#{BindPort}" unless Production
stdout_redirect "#{RailsRoot}/log/puma.stdout.log", "#{RailsRoot}/log/puma.stderr.log", true if Production

workers Workers unless RUBY_ENGINE == 'jruby'
threads 0,Threads

before_fork do
  ActiveRecord::Base.clear_all_connections!

  begin
    require 'puma_worker_killer'
    PumaWorkerKiller.config do |config|
      config.ram           = Workers * WorkerMaxMem # mb
      config.frequency     = 15                     # seconds
      config.percent_usage = 0.90
      config.rolling_restart_frequency = 12 * 3600  # 12 hours in seconds
    end
    PumaWorkerKiller.start
  rescue LoadError
    puts 'Add `puma_worker_killer` to `config/Gemfile` to use worker killer'
  end
end

after_worker_fork do |worker_nr|
  begin
    ActiveRecord::Base.establish_connection
    Rails.cache.reconnect
  rescue
    retry #if this fail it will stop worker init
  end

  WorkerDaemons.each do |daemon, opts|
    next unless opts[:worker_nr] == worker_nr
    t = Thread.new do
      sleep 2
      begin
        puts "#{worker_nr}: #{daemon}: starting"
        opts[:run].call
      rescue => e
        puts "#{worker_nr}: #{daemon}: failed: #{e.class} #{e.message}"
      end
    end
    t.priority = DaemonPriority
  end
end
