class AntiSpamPlugin::CommentWrapper < Struct.new(:comment)

  delegate :author_name, :author_email, :title, :body, :ip_address, :user_agent, :referrer, :to => :comment

  include Rakismet::Model

  alias :author :author_name
  alias :user_ip :ip_address
  alias :content :body

end
