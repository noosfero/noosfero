# encoding: utf-8

HTML::WhiteListSanitizer.module_eval do

  #unescape html comments
  def sanitize_with_filter_fixes(*args, &block)
    text = sanitize_without_filter_fixes(*args, &block)
    if text
      final_text = text.gsub(/&lt;!/, '<!')
      final_text = final_text.gsub(/<!--.*\[if IE\]-->(.*)<!--\[endif\]-->/, '<!–-[if IE]>\1<![endif]-–>') #FIX for itheora comments

      final_text = final_text.gsub(/&amp;quot;/, '&quot;') #FIX problems with archive.org
      final_text
    end
  end
  alias_method_chain :sanitize, :filter_fixes

end
