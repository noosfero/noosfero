require 'rails_helper'
require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'

RSpec.configure do |config|
  config.before :each, elasticsearch: true do
    puts '='*10, 'before', '='*10
    Elasticsearch::Extensions::Test::Cluster.start() unless Elasticsearch::Extensions::Test::Cluster.running?
  end

  config.after :suite do
    puts '='*10, 'after', '='*10
    Elasticsearch::Extensions::Test::Cluster.stop() if Elasticsearch::Extensions::Test::Cluster.running?
  end
end

RSpec.describe Community, type: :model, elasticsearch: true do
  before do
    Environment.create!(:name => 'Noosfero', :contact_email => 'noosfero@localhost.localdomain', :is_default => true)

    @environment = Environment.default
    @environment.enabled_plugins = ['ElasticsearchPlugin']
    @environment.save!

    @community = Community.new(name: "Debian")
    @community.save!

    sleep 2
  end

  it "assert true" do
    communities = Community.__elasticsearch__.search({}).records.to_a

    p communities

    expect(true).to be true
  end
end
