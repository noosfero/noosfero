class Scrap < ActiveRecord::Base

  attr_accessible :content, :sender_id, :receiver_id, :scrap_id

  SEARCHABLE_FIELDS = {
    :content => {:label => _('Content'), :weight => 1},
  }
  validates_presence_of :content
  validates_presence_of :sender_id, :receiver_id

  belongs_to :receiver, :class_name => 'Profile', :foreign_key => 'receiver_id'
  belongs_to :sender, :class_name => 'Person', :foreign_key => 'sender_id'
  has_many :replies, :class_name => 'Scrap', :foreign_key => 'scrap_id', :dependent => :destroy
  belongs_to :root, :class_name => 'Scrap', :foreign_key => 'scrap_id'

  has_many :profile_activities, foreign_key: :activity_id, conditions: {profile_activities: {activity_type: 'Scrap'}}, dependent: :destroy

  after_create :create_activity
  after_update :update_activity

  scope :all_scraps, lambda {|profile| {:conditions => ["receiver_id = ? OR sender_id = ?", profile, profile], :limit => 30}}

  scope :not_replies, :conditions => {:scrap_id => nil}

  track_actions :leave_scrap, :after_create, :keep_params => ['sender.name', 'content', 'receiver.name', 'receiver.url'], :if => Proc.new{|s| s.sender != s.receiver && s.sender != s.top_root.receiver}, :custom_target => :action_tracker_target

  track_actions :leave_scrap_to_self, :after_create, :keep_params => ['sender.name', 'content'], :if => Proc.new{|s| s.sender == s.receiver}

  track_actions :reply_scrap_on_self, :after_create, :keep_params => ['sender.name', 'content'], :if => Proc.new{|s| s.sender != s.receiver && s.sender == s.top_root.receiver}

  after_create :send_notification

  before_validation :strip_all_html_tags

  def top_root
    scrap = self
    scrap = Scrap.find(scrap.scrap_id) while scrap.scrap_id
    scrap
  end

  def strip_all_html_tags
    sanitizer = HTML::WhiteListSanitizer.new
    self.content = sanitizer.sanitize(self.content, :tags => [])
  end

  def action_tracker_target
    self.receiver.is_a?(Community) ? self.receiver : self
  end

  def is_root?
    !root.nil?
  end

  def scrap_wall_url
    is_root? ? root.receiver.wall_url : receiver.wall_url
  end

  def send_notification?
    sender != receiver && (is_root? ? root.receiver.receives_scrap_notification? : receiver.receives_scrap_notification?)
  end

  protected

  def create_activity
    # do not scrap replies (when scrap_id is not nil)
    return if self.scrap_id.present?
    ProfileActivity.create! profile_id: self.receiver_id, activity: self
  end

  def update_activity
    ProfileActivity.update_activity self
  end

  def send_notification
    self.root.update_attribute('updated_at', DateTime.now) unless self.root.nil?
    ScrapNotifier.notification(self).deliver if self.send_notification?
  end

end
