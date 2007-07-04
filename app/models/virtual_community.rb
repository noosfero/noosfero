class VirtualCommunity < ActiveRecord::Base

  has_many :domains, :as => :owner

  serialize :configuration, Hash
  def configuration
    self[:configuration] ||= Hash.new
  end

end
