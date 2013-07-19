require_dependency 'article'

class Article

  #FIXME make this test
  has_many :group_comments, :class_name => 'Comment', :foreign_key => 'source_id', :dependent => :destroy, :order => 'created_at asc', :conditions => [ 'group_id IS NOT NULL']

  #FIXME make this test
  validate :not_empty_group_comments_removed

  #FIXME make this test
  def not_empty_group_comments_removed
    if body
      groups_with_comments = group_comments.collect {|comment| comment.group_id}.uniq
      groups = Hpricot(body.to_s).search('.macro').collect{|element| element['data-macro-group_id'].to_i}
      errors.add_to_base(N_('Not empty group comment cannot be removed')) unless (groups_with_comments-groups).empty?
    end
  end

end

