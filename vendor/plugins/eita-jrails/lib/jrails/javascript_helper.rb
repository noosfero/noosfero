require 'action_view/helpers/javascript_helper'

module ActionView
  module Helpers
    JavaScriptHelper.module_eval do

      include ActionView::Helpers::JqueryHelper

      undef_method :button_to_function if method_defined? :button_to_function
      undef_method :link_to_function if method_defined? :link_to_function

      # Returns a button with the given +name+ text that'll trigger a JavaScript +function+ using the
      # onclick handler.
      #
      # The first argument +name+ is used as the button's value or display text.
      #
      # The next arguments are optional and may include the javascript function definition and a hash of html_options.
      #
      # The +function+ argument can be omitted in favor of an +update_page+
      # block, which evaluates to a string when the template is rendered
      # (instead of making an Ajax request first).
      #
      # The +html_options+ will accept a hash of html attributes for the link tag. Some examples are :class => "nav_button", :id => "articles_nav_button"
      #
      # Note: if you choose to specify the javascript function in a block, but would like to pass html_options, set the +function+ parameter to nil
      #
      # Examples:
      #   button_to_function "Greeting", "alert('Hello world!')"
      #   button_to_function "Delete", "if (confirm('Really?')) do_delete()"
      #   button_to_function "Details" do |page|
      #     page[:details].visual_effect :toggle_slide
      #   end
      #   button_to_function "Details", :class => "details_button" do |page|
      #     page[:details].visual_effect :toggle_slide
      #   end
      def button_to_function(name, *args, &block)
        html_options = args.extract_options!.symbolize_keys

        function = block_given? ? update_page(&block) : args[0] || ''
        onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function};"

        tag(:input, html_options.merge(:type => 'button', :value => name, :onclick => onclick))
      end

      #   link_to_function("Show me more", nil, :id => "more_link") do |page|
      #     page[:details].visual_effect  :toggle_blind
      #     page[:more_link].replace_html "Show me less"
      #   end
      #     Produces:
      #       <a href="#" id="more_link" onclick="try {
      #         $(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);
      #         $(&quot;more_link&quot;).update(&quot;Show me less&quot;);
      #       }
      #       catch (e) {
      #         alert('RJS error:\n\n' + e.toString());
      #         alert('$(\&quot;details\&quot;).visualEffect(\&quot;toggle_blind\&quot;);
      #         \n$(\&quot;more_link\&quot;).update(\&quot;Show me less\&quot;);');
      #         throw e
      #       };
      #       return false;">Show me more</a>
      #
      def link_to_function(name, *args, &block)
        html_options = args.extract_options!.symbolize_keys

        function = block_given? ? update_page(&block) : args[0] || ''
        onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
        href = html_options[:href] || '#'

        content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
      end

      # This function can be used to render rjs inline
      #
      # <%= javascript_function do |page|
      #   page.replace_html :list, :partial => 'list', :object => @list
      # end %>
      #
      def javascript_function(*args, &block)
        html_options = args.extract_options!
        function = args[0] || ''

        html_options.symbolize_keys!
        function = update_page(&block) if block_given?
        javascript_tag(function)
      end

      def jquery_id(id)
        id.to_s.count('#.*,>+~:[/ ') == 0 ? "##{id}" : id
      end

      def jquery_ids(ids)
        Array(ids).map{|id| jquery_id(id)}.join(',')
      end

    end
  end
end
