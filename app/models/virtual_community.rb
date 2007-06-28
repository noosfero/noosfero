class VirtualCommunity < ActiveRecord::Base
  validates_presence_of :domain
  validates_format_of :domain, :with => /^(\w+\.)+\w+$/


  serialize :features
  def features
    self[:features] ||= {}
  end
end
