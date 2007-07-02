class VirtualCommunity < ActiveRecord::Base

  has_many :domains, :as => :owner

  serialize :configuration
  def configuration
    self[:configuration] ||= {}
  end
end
