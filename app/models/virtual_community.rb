class VirtualCommunity < ActiveRecord::Base
  validates_presence_of :domain
  validates_format_of :domain, :with => /^(\w+\.)+\w+$/

  validates_presence_of :identifier
  validates_format_of :identifier, :with => /^[a-z][a-z0-9_]+[a-z0-9]$/

  serialize :features
  def features
    self[:features] ||= {}
  end
end
