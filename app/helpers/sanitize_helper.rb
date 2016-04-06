module SanitizeHelper

  def sanitize_html(text, type= :full_sanitize)
      sanitizer(type).sanitize(text, scrubber: permit_scrubber)
  end

  def sanitize_link(text)
      sanitizer(:white_list).sanitize(text, scrubber:permit_scrubber)
  end

protected

  def permit_scrubber
      scrubber = Rails::Html::PermitScrubber.new
      scrubber.tags = Rails.application.config.action_view.sanitized_allowed_tags
      scrubber.attributes = Rails.application.config.action_view.sanitized_allowed_attributes
      scrubber
  end

  def sanitizer type = :full_sanitize
    return HTML::WhiteListSanitizer.new if type == :white_list
    HTML::FullSanitizer.new
  end

end
