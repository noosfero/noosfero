require 'app/models/virtual_community'

class VirtualCommunity < ActiveRecord::Base
  def self.available_features
    {
    'feature1' => 'Enable Feature 1',
    'feature2' => 'Enable Feature 2',
    'feature3' => 'Enable Feature 3',
    }
  end
end
