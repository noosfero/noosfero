namespace :cypress do
  task :stop do
    `/bin/bash -c 'cat /tmp/noosfero.pid | xargs kill -9'`
  end

  task :start do
    `rails s -b 0.0.0.0 -d -e test -P /tmp/noosfero.pid`
  end

  task :prepareDB => :environment do
    p "Preparing test DB to run cypress tests"
    Rake::Task["cypress:stop"].invoke
    Rake::Task["db:test:prepare"].invoke
    Rake::Task["db:fixtures:load"].invoke
    p "Done."
  end

  task :run, [:tests] do |task, args|
    Rake::Task["cypress:prepareDB"].execute
    Rake::Task["cypress:start"].execute
    tests_to_run = get_args()
    if (tests_to_run.empty?)
      system("node_modules/cypress/bin/cypress run")
    else
      tests_to_run.each do |test|
        p test
        system("node_modules/cypress/bin/cypress run --spec '#{test}'")
      end
    end
  end
end

def get_args
  args_length = ARGV.length
  return ARGV[1..args_length]
end
