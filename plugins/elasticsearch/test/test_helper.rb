require 'test_helper'


require 'elasticsearch/extensions/test/cluster'
require 'elasticsearch/extensions/test/cluster/tasks'


def start_cluster
  if not Elasticsearch::Extensions::Test::Cluster.running?(on: 9250)
    Elasticsearch::Extensions::Test::Cluster.start
  end
end

def stop_cluster
  if Elasticsearch::Extensions::Test::Cluster.running?(on: 9250)
    Elasticsearch::Extensions::Test::Cluster.stop
  end
end


