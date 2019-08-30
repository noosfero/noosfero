class CommentParagraphPlugin::Discussion < Event
  def self.type_name
    _("Comments Discussion")
  end

  def self.short_description
    _("Comments Discussion")
  end

  def self.description
    _("Article with paragraph comments")
  end

  def accept_comments?
    current_time = Time.now
    super &&
      (start_date.nil? || current_time >= start_date) &&
      (end_date.nil? || current_time <= end_date)
  end
end
