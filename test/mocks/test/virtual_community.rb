require File.expand_path(File.dirname(__FILE__) +  "/../../../app/models/environment")

class Environment < ActiveRecord::Base
  def self.available_features
    {
    'feature1' => 'Enable Feature 1',
    'feature2' => 'Enable Feature 2',
    'feature3' => 'Enable Feature 3',
    }
  end
end
