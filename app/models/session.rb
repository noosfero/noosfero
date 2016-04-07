class Session < ActiveRecord::SessionStore::Session

  attr_accessible :session_id, :data

  # removed and redefined on super class
  def self.find_by_session_id session_id
    super
  end

  belongs_to :user

  before_save :copy_to_columns

  protected

  def copy_to_columns
    self.user_id = self.data['user']
  end

end
