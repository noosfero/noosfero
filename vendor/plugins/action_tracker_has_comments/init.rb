# monkey patch to add comments on action_tracker

Rails.configuration.to_prepare do
  ActionTracker::Record.module_eval do

    def comments
      type, id = if self.target_type == 'Article' then ['Article', self.target_id] else [self.class.to_s, self.id] end
      Comment.order('created_at ASC').
        where('comments.spam IS NOT TRUE AND comments.reply_of_id IS NULL').
        where('source_type = ? AND source_id = ?', type, id)
    end
  end
end
