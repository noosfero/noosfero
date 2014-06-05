# encoding: UTF-8

module TagsHelper

  module Cloud
    MAX_SIZE = 32
    MIN_SIZE = 12
  end

  # <tt>tags</tt> must be a hash where the keys are tag names and the values
  # the count of elements tagged with the tag, as returned by
  # Profile#tagged_with. If not tags were returned, just returns
  # _('No tags yet.')
  #
  # <tagname_option> must be a symbol representing the key to be inserted in
  # <tt>url</tt> with the tag name as value, if <tt>url</tt> is a Hash. If
  # <tt>url_options</tt> is a String, then the tag name is just appended to it.
  #
  # Example:
  #
  #   tag_cloud({ 'first-tag' => 10, 'second-tag' => 2, 'third-tag' => 1 }, :id, { :action => 'show_tag' })
  #
  # <tt>options</tt> can include one or more of the following:
  #
  # * <tt>:max_size</tt>: font size for the tag with largest count
  # * <tt>:min_size</tt>: font size for the tag with smallest count
  # * <tt>:show_count</tt>: whether to show the count of contents for each tag.   Defauls to <tt>false</tt>.
  #
  # The algorithm for generating the different sizes and positions is a
  # courtesy of Aurelio: http://www.colivre.coop.br/Aurium/Nuvem
  # (pt_BR only).
  def tag_cloud(tags, tagname_option, url, options = {})

    return content_tag('em', _('No tags yet.') + ' ') +
      link_to(content_tag(:span, _('What are tags?')),_('http://en.wikipedia.org/wiki/Tag_%28metadata%29')) if tags.empty?

    max_size = options[:max_size] || Cloud::MAX_SIZE
    min_size = options[:min_size] || Cloud::MIN_SIZE

    delta = max_size - min_size
    max = tags.values.max.to_f
    min = tags.values.min.to_f

    # Sorts first based on translated strings and then, if they are equal, based on the original form.
    # This way variant characters falls on the same level as their base characters and don't end up
    # at the end of the tag list.
    # Example: AA ÁA AB Z instead of AA AB Z ÁA
    tags.collect{ |k,v| [ActiveSupport::Inflector.transliterate(k).downcase, [k,v]] }.sort.collect { |ascii, t| t }.map do |tag,count|
      if ( max == min )
        v = 0.5
      else
        v = (count.to_f - min) / (max - min)
      end
      style = ""+
        "font-size: #{ (v * delta).round + min_size }px;"+
        "top: #{ -(delta/2) - (v * (delta/2)).round }px;"
      destination = url.merge(tagname_option => tag)

      if options[:show_count]
        display_count = options[:show_count] ? "<small><sup>(#{count})</sup></small>" : ""
        link_to tag + display_count, destination, :style => style
      else
        link_to h(tag) , destination, :style => style,
          :title => n_( 'one item', '%d items', count ) % count
      end

    end.join("\n").html_safe
  end

end
