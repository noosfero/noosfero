# monkey patch to fix WhiteListSanitizer bug
# http://apidock.com/rails/HTML/WhiteListSanitizer/process_attributes_for
#
# this was solved in rails 2.2.1, then remove this patch when upgrade to it

HTML::WhiteListSanitizer.module_eval do
  
  def sanitize_with_filter_fixes(*args, &block)
    text = sanitize_without_filter_fixes(*args, &block)
    if text
      final_text = text.gsub(/&lt;!/, '<!')
      final_text = final_text.gsub(/<!--.*\[if IE\]-->(.*)<!--\[endif\]-->/, '<!–-[if IE]>\1<![endif]-–>') #FIX for itheora comments

      if final_text =~ /iframe/
        itheora_video = /<iframe(.*)src=(.*)itheora.org(.*)<\/iframe>/
        sl_video = /<iframe(.*)src=\"http:\/\/(stream|tv).softwarelivre.org(.*)<\/iframe>/
        unless (final_text =~ itheora_video || final_text =~ sl_video)
          final_text = final_text.gsub(/<iframe(.*)<\/iframe>/, '')
        end
      end
      final_text = final_text.gsub(/&amp;quot;/, '&quot;') #FIX problems with archive.org
      final_text
    end
  end
  alias_method_chain :sanitize, :filter_fixes

  # unescape before reescape to avoid:
  # & -> &amp; -> &amp;amp; -> &amp;amp;amp; -> &amp;amp;amp;amp; -> etc
  protected
  def process_attributes_for(node, options)
    return unless node.attributes
    node.attributes.keys.each do |attr_name|
      value = node.attributes[attr_name].to_s

      if !options[:attributes].include?(attr_name) || contains_bad_protocols?(attr_name, value)
        node.attributes.delete(attr_name)
      else
        node.attributes[attr_name] = attr_name == 'style' ? sanitize_css(value) : CGI::escapeHTML(value.gsub('&amp;', '&'))
      end
    end
  end
end
