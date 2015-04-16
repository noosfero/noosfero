module InputHelper

  extend ActiveSupport::Concern
  protected

  def input_group_addon addon, options = {}, &block
    content_tag :div,
      content_tag(:span, addon, class: 'input-group-addon') + yield,
    class: 'input-group'
  end

end

module ApplicationHelper

  include InputHelper

end

