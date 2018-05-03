module TooltipHelper
  def tooltip(msg, size = :small)
    content = content_tag(:span, msg, class: "tooltip-msg #{size}")
    content_tag(:span, content, class: 'help-tooltip fas fa-question-circle')
  end
end
