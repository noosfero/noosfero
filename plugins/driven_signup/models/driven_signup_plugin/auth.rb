class DrivenSignupPlugin::Auth < ActiveRecord::Base

  attr_accessible :name, :token

  belongs_to :environment

  validates_presence_of :environment
  validates_presence_of :token
  validates_uniqueness_of :token, scope: :environment_id

  def token
    self[:token] ||= SecureRandom.hex 16
  end

end
