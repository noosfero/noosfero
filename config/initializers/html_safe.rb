##
# Object based copy of http://apidock.com/rails/ActionView/Helpers/OutputSafetyHelper/safe_join
# array.safe_join instead of safe_join(array)
#
class Array
  def safe_join sep=nil
    sep = ERB::Util.unwrapped_html_escape sep

    self.flatten.map!{ |i| ERB::Util.unwrapped_html_escape i }.join(sep).html_safe
  end
end

##
# Just use .to_json instead of .to_json.html_safe
# as escape_html_entities_in_json is default on rails.
# http://stackoverflow.com/a/31774454/670229
#
ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true
ActiveSupport::JSON.class_eval do
  module EncodeWithHtmlSafe
    def encode *args
      super.html_safe
    end
  end
  singleton_class.prepend EncodeWithHtmlSafe
end
