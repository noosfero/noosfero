unless ENV["RAILS_ENV"] == "production"
  require "rspec/core/rake_task"

  namespace :test do
    desc "Run the API tests in test/api"
    Rake::TestTask.new api: "db:test:prepare" do |t|
      t.libs << "test"
      t.pattern = "test/api/**/*_test.rb"
      t.warning = false
    end

    desc "Run the Rspec tests"
    RSpec::Core::RakeTask.new :specs
  end
end
