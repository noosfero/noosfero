# monkey patch to add comments on action_tracker

Rails.configuration.to_prepare do
  ActionTracker::Record.module_eval do

    has_many :comments, :class_name => 'Comment', :foreign_key => 'source_id', :dependent => :destroy, :finder_sql => 'SELECT * FROM comments WHERE #{conditions_for_comments} ORDER BY created_at ASC', :counter_sql => 'SELECT * FROM comments WHERE #{conditions_for_comments}'

    def conditions_for_comments
      type, id = (self.target_type == 'Article' ? ['Article', self.target_id] : [self.class.to_s, self.id])
      "source_type = '#{type}' AND source_id = '#{id}' AND spam IS NOT TRUE"
    end

    def comments_as_thread
      result = {}
      root = []
      self.comments.each do |c|
        c.replies = []
        result[c.id] ||= c
        if c.reply_of_id.nil?
          root << c
        elsif result[c.reply_of_id]
          result[c.reply_of_id].replies << c
        else # Comment is a reply but the reply is not being displayed - is spam, for example
          root << c
        end
      end
      root
    end

  end
end
