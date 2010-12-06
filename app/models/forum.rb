class Forum < Folder

  acts_as_having_posts :order => 'updated_at DESC'

  def self.short_description
    _('Forum')
  end

  def self.description
    _('An internet forum, also called message board, where discussions can be held.')
  end

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/forum_page'
    end
  end

  def forum?
    true
  end

end
