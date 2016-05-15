require 'rails_helper'
require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'

describe Community, type: :model, elasticsearch: true do
  before do
    @environment = Environment.default
    @environment.enabled_plugins = ['ElasticsearchPlugin']
    @environment.save!

    @community = Community.new(name: "Debian")
    @community.save!
    _start = Time.new
	Article.import
	sleep 4
	p Article.__elasticsearch__.client.cluster.health
  end

  it "assert true" do
    Article.__elasticsearch__.search({}).records.to_a
    expect(true).to be true
  end
end
