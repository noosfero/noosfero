module SanitizeTags
  extend ActiveSupport::Concern

  included do
    # xss_terminate plugin can't sanitize array fields
    # sanitize_tag_list is used with SanitizeHelper
    before_save :sanitize_tag_list
  end

  private

  def sanitize_tag_list
    self.tag_list.map!{|i| strip_tag_name (Rails::Html::FullSanitizer.new).sanitize(i) }
  end

  def strip_tag_name(tag_name)
    tag_name.gsub(/[<>]/, '')
  end
end
