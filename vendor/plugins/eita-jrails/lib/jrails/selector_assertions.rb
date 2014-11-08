require 'active_support/core_ext/module/aliasing'
require 'action_controller/vendor/html-scanner'
require 'action_dispatch/testing/assertions'
require 'action_dispatch/testing/assertions/selector'

#--
# Copyright (c) 2006 Assaf Arkin (http://labnotes.org)
# Under MIT and/or CC By license.
#++

ActionDispatch::Assertions::SelectorAssertions.module_eval do
  # Selects content from the RJS response.
  #
  # === Narrowing down
  #
  # With no arguments, asserts that one or more elements are updated or
  # inserted by RJS statements.
  #
  # Use the +id+ argument to narrow down the assertion to only statements
  # that update or insert an element with that identifier.
  #
  # Use the first argument to narrow down assertions to only statements
  # of that type. Possible values are <tt>:replace</tt>, <tt>:replace_html</tt>,
  # <tt>:show</tt>, <tt>:hide</tt>, <tt>:toggle</tt>, <tt>:remove</tta>,
  # <tt>:insert_html</tt> and <tt>:redirect</tt>.
  #
  # Use the argument <tt>:insert</tt> followed by an insertion position to narrow
  # down the assertion to only statements that insert elements in that
  # position. Possible values are <tt>:top</tt>, <tt>:bottom</tt>, <tt>:before</tt>
  # and <tt>:after</tt>.
  #
  # Use the argument <tt>:redirect</tt> followed by a path to check that an statement
  # which redirects to the specified path is generated.
  #
  # Using the <tt>:remove</tt> statement, you will be able to pass a block, but it will
  # be ignored as there is no HTML passed for this statement.
  #
  # === Using blocks
  #
  # Without a block, +assert_select_rjs+ merely asserts that the response
  # contains one or more RJS statements that replace or update content.
  #
  # With a block, +assert_select_rjs+ also selects all elements used in
  # these statements and passes them to the block. Nested assertions are
  # supported.
  #
  # Calling +assert_select_rjs+ with no arguments and using nested asserts
  # asserts that the HTML content is returned by one or more RJS statements.
  # Using +assert_select+ directly makes the same assertion on the content,
  # but without distinguishing whether the content is returned in an HTML
  # or JavaScript.
  #
  # ==== Examples
  #
  #   # Replacing the element foo.
  #   # page.replace 'foo', ...
  #   assert_select_rjs :replace, "foo"
  #
  #   # Replacing with the chained RJS proxy.
  #   # page[:foo].replace ...
  #   assert_select_rjs :chained_replace, 'foo'
  #
  #   # Inserting into the element bar, top position.
  #   assert_select_rjs :insert, :top, "bar"
  #
  #   # Remove the element bar
  #   assert_select_rjs :remove, "bar"
  #
  #   # Changing the element foo, with an image.
  #   assert_select_rjs "foo" do
  #     assert_select "img[src=/images/logo.gif""
  #   end
  #
  #   # RJS inserts or updates a list with four items.
  #   assert_select_rjs do
  #     assert_select "ol>li", 4
  #   end
  #
  #   # The same, but shorter.
  #   assert_select "ol>li", 4
  #
  #   # Checking for a redirect.
  #   assert_select_rjs :redirect, root_path
  def assert_select_rjs(*args, &block)
    rjs_type = args.first.is_a?(Symbol) ? args.shift : nil
    id       = args.first.is_a?(String) ? args.shift : nil

    # If the first argument is a symbol, it's the type of RJS statement we're looking
    # for (update, replace, insertion, etc). Otherwise, we're looking for just about
    # any RJS statement.
    if rjs_type
      if rjs_type == :insert
        position  = args.shift
        id = args.shift
        insertion = "insert_#{position}".to_sym
        raise ArgumentError, "Unknown RJS insertion type #{position}" unless RJS_STATEMENTS[insertion]
        statement = "(#{RJS_STATEMENTS[insertion]})"
      else
        raise ArgumentError, "Unknown RJS statement type #{rjs_type}" unless RJS_STATEMENTS[rjs_type]
        statement = "(#{RJS_STATEMENTS[rjs_type]})"
      end
    else
      statement = "#{RJS_STATEMENTS[:any]}"
    end

    # Next argument we're looking for is the element identifier. If missing, we pick
    # any element, otherwise we replace it in the statement.
    pattern = Regexp.new(
      id ? statement.gsub(RJS_ANY_ID, "\"#{id}\"") : statement
    )

    # Duplicate the body since the next step involves destroying it.
    matches = nil
    case rjs_type
      when :remove, :show, :hide, :toggle
        matches = @response.body.match(pattern)
      else
        @response.body.gsub(pattern) do |match|
          html = unescape_rjs(match)
          matches ||= []
          matches.concat HTML::Document.new(html).root.children.select { |n| n.tag? }
          ""
        end
    end

    if matches
      assert true # to count the assertion
      if block_given? && !([:remove, :show, :hide, :toggle].include? rjs_type)
        begin
          @selected ||= nil
          in_scope, @selected = @selected, matches
          yield matches
        ensure
          @selected = in_scope
        end
      end
      matches
    else
      # RJS statement not found.
      case rjs_type
        when :remove, :show, :hide, :toggle
          flunk_message = "No RJS statement that #{rjs_type.to_s}s '#{id}' was rendered."
        else
          flunk_message = "No RJS statement that replaces or inserts HTML content."
      end
      flunk args.shift || flunk_message
    end
  end

  protected

  RJS_PATTERN_HTML  = "\"((\\\\\"|[^\"])*)\""
  RJS_ANY_ID        = "[\"']([^\"])*[\"']"

  RJS_STATEMENTS   = {
    :chained_replace      => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.replaceWith\\(#{RJS_PATTERN_HTML}\\)",
    :chained_replace_html => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.updateWith\\(#{RJS_PATTERN_HTML}\\)",
    :replace_html         => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.html\\(#{RJS_PATTERN_HTML}\\)",
    :insert_html          => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.append\\(#{RJS_PATTERN_HTML}\\)",
    :replace              => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.replaceWith\\(#{RJS_PATTERN_HTML}\\)",
    :insert_top           => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.prepend\\(#{RJS_PATTERN_HTML}\\)",
    :insert_bottom        => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.append\\(#{RJS_PATTERN_HTML}\\)",
    :effect               => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.effect\\(",
    :highlight            => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.effect\\('highlight'"
  }
  [:remove, :show, :hide, :toggle, :reset ].each do |action|
    RJS_STATEMENTS[action] = "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.#{action}\\(\\)"
  end

  RJS_STATEMENTS[:any] = Regexp.new("(#{RJS_STATEMENTS.values.join('|')})")
  RJS_PATTERN_UNICODE_ESCAPED_CHAR = /\\u([0-9a-zA-Z]{4})/

  # +assert_select+ and +css_select+ call this to obtain the content in the HTML
  # page, or from all the RJS statements, depending on the type of response.
  def response_from_page_with_rjs
    content_type = @response.content_type

    if content_type && Mime::JS =~ content_type
      body = @response.body.dup
      root = HTML::Node.new(nil)

      while true
        next if body.sub!(RJS_STATEMENTS[:any]) do |match|
          html = unescape_rjs(match)
          matches = HTML::Document.new(html).root.children.select { |n| n.tag? }
          root.children.concat matches
          ""
        end
        break
      end

      root
    else
      response_from_page_without_rjs
    end
  end
  alias_method_chain :response_from_page, :rjs

  # Unescapes a RJS string.
  def unescape_rjs(rjs_string)
    # RJS encodes double quotes and line breaks.
    unescaped= rjs_string.gsub('\"', '"')
    unescaped.gsub!(/\\\//, '/')
    unescaped.gsub!('\n', "\n")
    unescaped.gsub!('\076', '>')
    unescaped.gsub!('\074', '<')
    # RJS encodes non-ascii characters.
    unescaped.gsub!(RJS_PATTERN_UNICODE_ESCAPED_CHAR) {|u| [$1.hex].pack('U*')}
    unescaped
  end
end
