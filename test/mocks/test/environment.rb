require File.expand_path(File.dirname(__FILE__) +  "/../../../app/models/environment")

class Environment < ApplicationRecord
  def self.available_features
    {
    'feature1' => 'Enable Feature 1',
    'feature2' => 'Enable Feature 2',
    'feature3' => 'Enable Feature 3',
    'xmpp_chat' => 'Feature to enable/disabled chat (required here to make tests)',
    }
  end
end
