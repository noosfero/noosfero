require_dependency 'comment'

class Comment

  scope :without_paragraph, :conditions => {:paragraph_uuid => nil }

  settings_items :comment_paragraph_selected_area, :type => :string
  settings_items :comment_paragraph_selected_content, :type => :string

  scope :in_paragraph, proc { |paragraph_uuid| {
      :conditions => ['paragraph_uuid = ?', paragraph_uuid]
    }
  }

  attr_accessible :paragraph_uuid, :comment_paragraph_selected_area, :id, :comment_paragraph_selected_content

  before_validation do |comment|
    comment.comment_paragraph_selected_area = nil if comment.comment_paragraph_selected_area.blank?
    comment.comment_paragraph_selected_content = nil if comment_paragraph_selected_content.blank?
  end

end
