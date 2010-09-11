class Scrap < ActiveRecord::Base
  validates_presence_of :content
  validates_presence_of :sender_id, :receiver_id

  belongs_to :receiver, :class_name => 'Person', :foreign_key => 'receiver_id'
  belongs_to :sender, :class_name => 'Person', :foreign_key => 'sender_id'
  has_many :replies, :class_name => 'Scrap', :foreign_key => 'scrap_id', :dependent => :destroy
  belongs_to :root, :class_name => 'Scrap', :foreign_key => 'scrap_id'

  named_scope :all_scraps, lambda {|profile| {:conditions => ["receiver_id = ? OR sender_id = ?", profile, profile], :limit => 30}}

  named_scope :not_replies, :conditions => {:scrap_id => nil}

  track_actions :leave_scrap, :after_create, :keep_params => ['sender.name', 'content', 'receiver.name', 'receiver.url'], :if => Proc.new{|s| s.receiver != s.sender}
  track_actions :leave_scrap_to_self, :after_create, :keep_params => ['sender.name', 'content'], :if => Proc.new{|s| s.receiver == s.sender}

  after_create do |scrap|
    scrap.root.update_attribute('updated_at', DateTime.now) unless scrap.root.nil?
  end

  before_validation :strip_all_html_tags

  def strip_all_html_tags
    sanitizer = HTML::WhiteListSanitizer.new
    self.content = sanitizer.sanitize(self.content, :tags => [])
  end

end
