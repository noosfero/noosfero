require_dependency 'article'

class Article

  has_many :group_comments, :class_name => 'Comment', :foreign_key => 'source_id', :dependent => :destroy, :order => 'created_at asc', :conditions => [ 'group_id IS NOT NULL']

  validate :not_empty_group_comments_removed

  def not_empty_group_comments_removed
    if body && body_changed?
      groups_with_comments = Comment.find(:all, :select => 'distinct group_id', :conditions => {:source_id => self.id}).map(&:group_id).compact
      groups = Nokogiri::HTML.fragment(body.to_s).css('.macro').collect{|element| element['data-macro-group_id'].to_i}
      errors[:base] << (N_('Not empty group comment cannot be removed')) unless (groups_with_comments-groups).empty?
    end
  end

end

