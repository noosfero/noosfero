module InputHelper

  extend ActiveSupport::Concern
  protected

  def input_group_addon addon, options = {}, &block
<<<<<<< HEAD
    content_tag :div,
      content_tag(:span, addon, class: 'input-group-addon') + yield,
    class: 'input-group'
=======
    content_tag :div, class: 'input-group' do
      [
        content_tag(:span, addon, class: 'input-group-addon'),
        capture(&block),
      ].safe_join
    end
>>>>>>> 2ef3a43... responsive: fix html_safe issues
  end

end

<<<<<<< HEAD
module ApplicationHelper

  include InputHelper

end
=======
ApplicationHelper.include InputHelper
>>>>>>> 2ef3a43... responsive: fix html_safe issues

