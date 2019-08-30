class Scrap < ApplicationRecord
  include SanitizeHelper
  include Noosfero::Plugin::HotSpot
  include Notifiable

  attr_accessible :content, :sender_id, :receiver_id, :scrap_id, :marked_people

  SEARCHABLE_FIELDS = {
    content: { label: _("Content"), weight: 1 },
  }
  validates_presence_of :content
  validates_presence_of :sender_id, :receiver_id

  belongs_to :receiver, class_name: "Profile", foreign_key: "receiver_id", optional: true
  belongs_to :sender, class_name: "Person", foreign_key: "sender_id", optional: true
  has_many :replies, class_name: "Scrap", foreign_key: "scrap_id", dependent: :destroy
  belongs_to :root, class_name: "Scrap", foreign_key: "scrap_id", optional: true

  has_many :profile_activities, -> {
    where profile_activities: { activity_type: "Scrap" }
  }, foreign_key: :activity_id, dependent: :destroy

  has_and_belongs_to_many :marked_people, join_table: :private_scraps, class_name: "Person"

  after_create :create_activity
  after_update :update_activity

  scope :all_scraps, ->profile { limit(30).where("receiver_id = ? OR sender_id = ?", profile, profile) }

  scope :not_replies, -> { where scrap_id: nil }

  track_actions :leave_scrap, :after_create, keep_params: ["sender.name", "content", "receiver.name", "receiver.url"], if: Proc.new { |s| s.sender != s.receiver && s.sender != s.top_root.receiver }, custom_target: :action_tracker_target, custom_user: :sender

  track_actions :leave_scrap_to_self, :after_create, keep_params: ["sender.name", "content"], if: Proc.new { |s| s.sender == s.receiver }, custom_user: :sender

  track_actions :reply_scrap_on_self, :after_create, keep_params: ["sender.name", "content", "receiver.name", "receiver.url"], if: Proc.new { |s| s.sender != s.receiver && s.sender == s.top_root.receiver }, custom_user: :sender

  after_create :send_notification

  before_validation :strip_all_html_tags

  will_notify :new_scrap, push: true

  alias :user :sender
  alias :target :receiver

  def top_root
    scrap = self
    scrap = Scrap.find(scrap.scrap_id) while scrap.scrap_id
    scrap
  end

  def strip_all_html_tags
    self.content = sanitize_html(self.content)
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

  def display_to?(user = nil)
    marked_people.blank? || marked_people.include?(user)
  end

  def environment
    self.receiver.environment
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
      self.root.update_attribute("updated_at", DateTime.now) unless self.root.nil?
      notify(:new_scrap, self) if self.send_notification?
    end

    def new_scrap_notification
      if self.receiver.respond_to?(:push_subscriptions)
        {
          title: _("You got a new scrap"),
          body: _("%s left a scrap in your wall.") % self.sender.name,
          recipients: [self.receiver]
        }
      end
    end
end
