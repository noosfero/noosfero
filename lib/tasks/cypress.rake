namespace :cypress do
  namespace :server do
    task :stop do
      p "stoping test server"
      `/bin/bash -c 'cat /tmp/noosfero.pid | xargs kill -9'`
      p "stoped"
    end

    task :start do
      p "starting test server"
      `rails s -b 0.0.0.0 -d -e test -P /tmp/noosfero.pid`
      p "started"
    end

    task prepareDB: :environment do
      Rake::Task["cypress:server:stop"].execute
      p "Preparing test database"
      Rake::Task["db:test:prepare"].execute
      p "Loading fixtures."
      Rake::Task["db:fixtures:load"].execute
      p "Done."
    end
  end
end
