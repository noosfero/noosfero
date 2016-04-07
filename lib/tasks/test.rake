namespace :test do
  desc "Run the API tests in test/api"
  Rake::TestTask.new api: "db:test:prepare" do |t|
    t.libs << 'test'
    t.pattern = 'test/api/**/*_test.rb'
    t.warning = false
  end
end
