require 'action_view/helpers/javascript_proxies'
require 'action_view/helpers/jquery_helper/generator'

module ActionView
  module Helpers
    module JqueryHelper

      JQUERY_VAR = ::JRails::JQUERY_VAR

      USE_PROTECTION = const_defined?(:DISABLE_JQUERY_FORGERY_PROTECTION) ? !DISABLE_JQUERY_FORGERY_PROTECTION : true

      unless const_defined? :JQCALLBACKS
        JQCALLBACKS = Set.new([ :beforeSend, :complete, :error, :success ] + (100..599).to_a)
        #instance_eval { remove_const :AJAX_OPTIONS }
        remove_const(:AJAX_OPTIONS) if const_defined?(:AJAX_OPTIONS)
        AJAX_OPTIONS = Set.new([ :before, :after, :condition, :url,
                         :asynchronous, :method, :insertion, :position,
                         :form, :with, :update, :script ]).merge(JQCALLBACKS)
      end

      # Periodically calls the specified url (<tt>options[:url]</tt>) every
      # <tt>options[:frequency]</tt> seconds (default is 10). Usually used to
      # update a specified div (<tt>options[:update]</tt>) with the results
      # of the remote call. The options for specifying the target with <tt>:url</tt>
      # and defining callbacks is the same as link_to_remote.
      # Examples:
      #  # Call get_averages and put its results in 'avg' every 10 seconds
      #  # Generates:
      #  #      new PeriodicalExecuter(function() {new Ajax.Updater('avg', '/grades/get_averages',
      #  #      {asynchronous:true, evalScripts:true})}, 10)
      #  periodically_call_remote(:url => { :action => 'get_averages' }, :update => 'avg')
      #
      #  # Call invoice every 10 seconds with the id of the customer
      #  # If it succeeds, update the invoice DIV; if it fails, update the error DIV
      #  # Generates:
      #  #      new PeriodicalExecuter(function() {new Ajax.Updater({success:'invoice',failure:'error'},
      #  #      '/testing/invoice/16', {asynchronous:true, evalScripts:true})}, 10)
      #  periodically_call_remote(:url => { :action => 'invoice', :id => customer.id },
      #     :update => { :success => "invoice", :failure => "error" }
      #
      #  # Call update every 20 seconds and update the new_block DIV
      #  # Generates:
      #  # new PeriodicalExecuter(function() {new Ajax.Updater('news_block', 'update', {asynchronous:true, evalScripts:true})}, 20)
      #  periodically_call_remote(:url => 'update', :frequency => '20', :update => 'news_block')
      #
      def periodically_call_remote(options = {})
        frequency = options[:frequency] || 10 # every ten seconds by default
        code = "setInterval(function() {#{remote_function(options)}}, #{frequency} * 1000)"
        javascript_tag(code)
      end

      def remote_function(options)
        javascript_options = options_for_ajax(options)

        update = ''
        if options[:update] && options[:update].is_a?(Hash)
          update  = []
          update << "success:'#{options[:update][:success]}'" if options[:update][:success]
          update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
          update  = '{' + update.join(',') + '}'
        elsif options[:update]
          update << "'#{options[:update]}'"
        end

        function = "#{JQUERY_VAR}.ajax(#{javascript_options})"

        function = "#{options[:before]}; #{function}" if options[:before]
        function = "#{function}; #{options[:after]}"  if options[:after]
        function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
        function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]
        return function
      end

      # Creates a button with an onclick event which calls a remote action
      # via XMLHttpRequest
      # The options for specifying the target with :url
      # and defining callbacks is the same as link_to_remote.
      def button_to_remote(name, options = {}, html_options = {})
        button_to_function(name, remote_function(options), html_options)
      end

      # Returns a button input tag with the element name of +name+ and a value (i.e., display text) of +value+
      # that will submit form using XMLHttpRequest in the background instead of a regular POST request that
      # reloads the page.
      #
      #  # Create a button that submits to the create action
      #  #
      #  # Generates: <input name="create_btn" onclick="new Ajax.Request('/testing/create',
      #  #     {asynchronous:true, evalScripts:true, parameters:Form.serialize(this.form)});
      #  #     return false;" type="button" value="Create" />
      #  <%= submit_to_remote 'create_btn', 'Create', :url => { :action => 'create' } %>
      #
      #  # Submit to the remote action update and update the DIV succeed or fail based
      #  # on the success or failure of the request
      #  #
      #  # Generates: <input name="update_btn" onclick="new Ajax.Updater({success:'succeed',failure:'fail'},
      #  #      '/testing/update', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this.form)});
      #  #      return false;" type="button" value="Update" />
      #  <%= submit_to_remote 'update_btn', 'Update', :url => { :action => 'update' },
      #     :update => { :success => "succeed", :failure => "fail" }
      #
      # <tt>options</tt> argument is the same as in form_remote_tag.
      def submit_to_remote(name, value, options = {})
        options[:with] ||= "#{JQUERY_VAR}(this.form).serialize()"

        html_options = options.delete(:html) || {}
        html_options[:name] = name

        button_to_remote(value, options, html_options)
      end

      # Returns a link to a remote action defined by <tt>options[:url]</tt>
      # (using the url_for format) that's called in the background using
      # XMLHttpRequest. The result of that request can then be inserted into a
      # DOM object whose id can be specified with <tt>options[:update]</tt>.
      # Usually, the result would be a partial prepared by the controller with
      # render :partial.
      #
      # Examples:
      #   # Generates: <a href="#" onclick="new Ajax.Updater('posts', '/blog/destroy/3', {asynchronous:true, evalScripts:true});
      #   #            return false;">Delete this post</a>
      #   link_to_remote "Delete this post", :update => "posts",
      #     :url => { :action => "destroy", :id => post.id }
      #
      #   # Generates: <a href="#" onclick="new Ajax.Updater('emails', '/mail/list_emails', {asynchronous:true, evalScripts:true});
      #   #            return false;"><img alt="Refresh" src="/images/refresh.png?" /></a>
      #   link_to_remote(image_tag("refresh"), :update => "emails",
      #     :url => { :action => "list_emails" })
      #
      # You can override the generated HTML options by specifying a hash in
      # <tt>options[:html]</tt>.
      #
      #   link_to_remote "Delete this post", :update => "posts",
      #     :url  => post_url(@post), :method => :delete,
      #     :html => { :class  => "destructive" }
      #
      # You can also specify a hash for <tt>options[:update]</tt> to allow for
      # easy redirection of output to an other DOM element if a server-side
      # error occurs:
      #
      # Example:
      #   # Generates: <a href="#" onclick="new Ajax.Updater({success:'posts',failure:'error'}, '/blog/destroy/5',
      #   #            {asynchronous:true, evalScripts:true}); return false;">Delete this post</a>
      #   link_to_remote "Delete this post",
      #     :url => { :action => "destroy", :id => post.id },
      #     :update => { :success => "posts", :failure => "error" }
      #
      # Optionally, you can use the <tt>options[:position]</tt> parameter to
      # influence how the target DOM element is updated. It must be one of
      # <tt>:before</tt>, <tt>:top</tt>, <tt>:bottom</tt>, or <tt>:after</tt>.
      #
      # The method used is by default POST. You can also specify GET or you
      # can simulate PUT or DELETE over POST. All specified with <tt>options[:method]</tt>
      #
      # Example:
      #   # Generates: <a href="#" onclick="new Ajax.Request('/person/4', {asynchronous:true, evalScripts:true, method:'delete'});
      #   #            return false;">Destroy</a>
      #   link_to_remote "Destroy", :url => person_url(:id => person), :method => :delete
      #
      # By default, these remote requests are processed asynchronous during
      # which various JavaScript callbacks can be triggered (for progress
      # indicators and the likes). All callbacks get access to the
      # <tt>request</tt> object, which holds the underlying XMLHttpRequest.
      #
      # To access the server response, use <tt>request.responseText</tt>, to
      # find out the HTTP status, use <tt>request.status</tt>.
      #
      # Example:
      #   # Generates: <a href="#" onclick="new Ajax.Request('/words/undo?n=33', {asynchronous:true, evalScripts:true,
      #   #            onComplete:function(request){undoRequestCompleted(request)}}); return false;">hello</a>
      #   word = 'hello'
      #   link_to_remote word,
      #     :url => { :action => "undo", :n => word_counter },
      #     :complete => "undoRequestCompleted(request)"
      #
      # The callbacks that may be specified are (in order):
      #
      # <tt>:loading</tt>::       Called when the remote document is being
      #                           loaded with data by the browser.
      # <tt>:loaded</tt>::        Called when the browser has finished loading
      #                           the remote document.
      # <tt>:interactive</tt>::   Called when the user can interact with the
      #                           remote document, even though it has not
      #                           finished loading.
      # <tt>:success</tt>::       Called when the XMLHttpRequest is completed,
      #                           and the HTTP status code is in the 2XX range.
      # <tt>:failure</tt>::       Called when the XMLHttpRequest is completed,
      #                           and the HTTP status code is not in the 2XX
      #                           range.
      # <tt>:complete</tt>::      Called when the XMLHttpRequest is complete
      #                           (fires after success/failure if they are
      #                           present).
      #
      # You can further refine <tt>:success</tt> and <tt>:failure</tt> by
      # adding additional callbacks for specific status codes.
      #
      # Example:
      #   # Generates: <a href="#" onclick="new Ajax.Request('/testing/action', {asynchronous:true, evalScripts:true,
      #   #            on404:function(request){alert('Not found...? Wrong URL...?')},
      #   #            onFailure:function(request){alert('HTTP Error ' + request.status + '!')}}); return false;">hello</a>
      #   link_to_remote word,
      #     :url => { :action => "action" },
      #     404 => "alert('Not found...? Wrong URL...?')",
      #     :failure => "alert('HTTP Error ' + request.status + '!')"
      #
      # A status code callback overrides the success/failure handlers if
      # present.
      #
      # If you for some reason or another need synchronous processing (that'll
      # block the browser while the request is happening), you can specify
      # <tt>options[:type] = :synchronous</tt>.
      #
      # You can customize further browser side call logic by passing in
      # JavaScript code snippets via some optional parameters. In their order
      # of use these are:
      #
      # <tt>:confirm</tt>::      Adds confirmation dialog.
      # <tt>:condition</tt>::    Perform remote request conditionally
      #                          by this expression. Use this to
      #                          describe browser-side conditions when
      #                          request should not be initiated.
      # <tt>:before</tt>::       Called before request is initiated.
      # <tt>:after</tt>::        Called immediately after request was
      #                          initiated and before <tt>:loading</tt>.
      # <tt>:submit</tt>::       Specifies the DOM element ID that's used
      #                          as the parent of the form elements. By
      #                          default this is the current form, but
      #                          it could just as well be the ID of a
      #                          table row or any other DOM element.
      # <tt>:with</tt>::         A JavaScript expression specifying
      #                          the parameters for the XMLHttpRequest.
      #                          Any expressions should return a valid
      #                          URL query string.
      #
      #                          Example:
      #
      #                            :with => "'name=' + $('name').value"
      #
      # You can generate a link that uses AJAX in the general case, while
      # degrading gracefully to plain link behavior in the absence of
      # JavaScript by setting <tt>html_options[:href]</tt> to an alternate URL.
      # Note the extra curly braces around the <tt>options</tt> hash separate
      # it as the second parameter from <tt>html_options</tt>, the third.
      #
      # Example:
      #   link_to_remote "Delete this post",
      #     { :update => "posts", :url => { :action => "destroy", :id => post.id } },
      #     :href => url_for(:action => "destroy", :id => post.id)
      def link_to_remote(name, options = {}, html_options = nil)
        link_to_function(name, remote_function(options), html_options || options.delete(:html))
      end

      # Returns a form tag that will submit using XMLHttpRequest in the
      # background instead of the regular reloading POST arrangement. Even
      # though it's using JavaScript to serialize the form elements, the form
      # submission will work just like a regular submission as viewed by the
      # receiving side (all elements available in <tt>params</tt>). The options for
      # specifying the target with <tt>:url</tt> and defining callbacks is the same as
      # +link_to_remote+.
      #
      # A "fall-through" target for browsers that doesn't do JavaScript can be
      # specified with the <tt>:action</tt>/<tt>:method</tt> options on <tt>:html</tt>.
      #
      # Example:
      #   # Generates:
      #   #      <form action="/some/place" method="post" onsubmit="new Ajax.Request('',
      #   #      {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)}); return false;">
      #   form_remote_tag :html => { :action =>
      #     url_for(:controller => "some", :action => "place") }
      #
      # The Hash passed to the <tt>:html</tt> key is equivalent to the options (2nd)
      # argument in the FormTagHelper.form_tag method.
      #
      # By default the fall-through action is the same as the one specified in
      # the <tt>:url</tt> (and the default method is <tt>:post</tt>).
      #
      # form_remote_tag also takes a block, like form_tag:
      #   # Generates:
      #   #     <form action="/" method="post" onsubmit="new Ajax.Request('/',
      #   #     {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)});
      #   #     return false;"> <div><input name="commit" type="submit" value="Save" /></div>
      #   #     </form>
      #   <% form_remote_tag :url => '/posts' do -%>
      #     <div><%= submit_tag 'Save' %></div>
      #   <% end -%>
      def form_remote_tag(options = {}, &block)
        options[:form] = true

        options[:html] ||= {}
        options[:html][:onsubmit] =
          (options[:html][:onsubmit] ? options[:html][:onsubmit] + "; " : "") +
          "#{remote_function(options)}; return false;"

        form_tag(options[:html].delete(:action) || url_for(options[:url]), options[:html], &block)
      end

      # Creates a form that will submit using XMLHttpRequest in the background
      # instead of the regular reloading POST arrangement and a scope around a
      # specific resource that is used as a base for questioning about
      # values for the fields.
      #
      # === Resource
      #
      # Example:
      #   <% remote_form_for(@post) do |f| %>
      #     ...
      #   <% end %>
      #
      # This will expand to be the same as:
      #
      #   <% remote_form_for :post, @post, :url => post_path(@post), :html => { :method => :put, :class => "edit_post", :id => "edit_post_45" } do |f| %>
      #     ...
      #   <% end %>
      #
      # === Nested Resource
      #
      # Example:
      #   <% remote_form_for([@post, @comment]) do |f| %>
      #     ...
      #   <% end %>
      #
      # This will expand to be the same as:
      #
      #   <% remote_form_for :comment, @comment, :url => post_comment_path(@post, @comment), :html => { :method => :put, :class => "edit_comment", :id => "edit_comment_45" } do |f| %>
      #     ...
      #   <% end %>
      #
      # If you don't need to attach a form to a resource, then check out form_remote_tag.
      #
      # See FormHelper#form_for for additional semantics.
      def remote_form_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!

        case record_or_name_or_array
        when String, Symbol
          object_name = record_or_name_or_array
        when Array
          object = record_or_name_or_array.last
          object_name = ActiveModel::Naming.singular(object)
          apply_form_for_options!(record_or_name_or_array, options)
          args.unshift object
        else
          object      = record_or_name_or_array
          object_name = ActiveModel::Naming.singular(record_or_name_or_array)
          apply_form_for_options!(object, options)
          args.unshift object
        end

        form_remote_tag options do
          fields_for object_name, *(args << options), &proc
        end
      end
      alias_method :form_remote_for, :remote_form_for

      # Returns '<tt>eval(request.responseText)</tt>' which is the JavaScript function
      # that +form_remote_tag+ can call in <tt>:complete</tt> to evaluate a multiple
      # update return document using +update_element_function+ calls.
      def evaluate_remote_response
        "#{JQUERY_VAR}.globalEval(request.responseText)"
      end

      # Observes the field with the DOM ID specified by +field_id+ and calls a
      # callback when its contents have changed. The default callback is an
      # Ajax call. By default the value of the observed field is sent as a
      # parameter with the Ajax call.
      #
      # Example:
      #  # Generates: new Form.Element.Observer('suggest', 0.25, function(element, value) {new Ajax.Updater('suggest',
      #  #         '/testing/find_suggestion', {asynchronous:true, evalScripts:true, parameters:'q=' + value})})
      #  <%= observe_field :suggest, :url => { :action => :find_suggestion },
      #       :frequency => 0.25,
      #       :update => :suggest,
      #       :with => 'q'
      #       %>
      #
      # Required +options+ are either of:
      # <tt>:url</tt>::       +url_for+-style options for the action to call
      #                       when the field has changed.
      # <tt>:function</tt>::  Instead of making a remote call to a URL, you
      #                       can specify javascript code to be called instead.
      #                       Note that the value of this option is used as the
      #                       *body* of the javascript function, a function definition
      #                       with parameters named element and value will be generated for you
      #                       for example:
      #                         observe_field("glass", :frequency => 1, :function => "alert('Element changed')")
      #                       will generate:
      #                         new Form.Element.Observer('glass', 1, function(element, value) {alert('Element changed')})
      #                       The element parameter is the DOM element being observed, and the value is its value at the
      #                       time the observer is triggered.
      #
      # Additional options are:
      # <tt>:frequency</tt>:: The frequency (in seconds) at which changes to
      #                       this field will be detected. Not setting this
      #                       option at all or to a value equal to or less than
      #                       zero will use event based observation instead of
      #                       time based observation.
      # <tt>:update</tt>::    Specifies the DOM ID of the element whose
      #                       innerHTML should be updated with the
      #                       XMLHttpRequest response text.
      # <tt>:with</tt>::      A JavaScript expression specifying the parameters
      #                       for the XMLHttpRequest. The default is to send the
      #                       key and value of the observed field. Any custom
      #                       expressions should return a valid URL query string.
      #                       The value of the field is stored in the JavaScript
      #                       variable +value+.
      #
      #                       Examples
      #
      #                         :with => "'my_custom_key=' + value"
      #                         :with => "'person[name]=' + prompt('New name')"
      #                         :with => "Form.Element.serialize('other-field')"
      #
      #                       Finally
      #                         :with => 'name'
      #                       is shorthand for
      #                         :with => "'name=' + value"
      #                       This essentially just changes the key of the parameter.
      #
      # Additionally, you may specify any of the options documented in the
      # <em>Common options</em> section at the top of this document.
      #
      # Example:
      #
      #   # Sends params: {:title => 'Title of the book'} when the book_title input
      #   # field is changed.
      #   observe_field 'book_title',
      #     :url => 'http://example.com/books/edit/1',
      #     :with => 'title'
      #
      #
      def observe_field(field_id, options = {})
        build_observer(field_id, options)
      end

      # Observes the form with the DOM ID specified by +form_id+ and calls a
      # callback when its contents have changed. The default callback is an
      # Ajax call. By default all fields of the observed field are sent as
      # parameters with the Ajax call.
      #
      # The +options+ for +observe_form+ are the same as the options for
      # +observe_field+. The JavaScript variable +value+ available to the
      # <tt>:with</tt> option is set to the serialized form by default.
      def observe_form(form_id, options = {})
        build_observer(form_id, options)
      end

      # Yields a JavaScriptGenerator and returns the generated JavaScript code.
      # Use this to update multiple elements on a page in an Ajax response.
      # See JavaScriptGenerator for more information.
      #
      # Example:
      #
      #   update_page do |page|
      #     page.hide 'spinner'
      #   end
      def update_page(&block)
        JavaScriptGenerator.new(self, &block).to_s.html_safe
      end

      # Works like update_page but wraps the generated JavaScript in a
      # <tt>\<script></tt> tag. Use this to include generated JavaScript in an
      # ERb template. See JavaScriptGenerator for more information.
      #
      # +html_options+ may be a hash of <tt>\<script></tt> attributes to be
      # passed to ActionView::Helpers::JavaScriptHelper#javascript_tag.
      def update_page_tag(html_options = {}, &block)
        javascript_tag update_page(&block), html_options
      end

      def method_option_to_s method
        (method.is_a?(String) and !method.index("'").nil?) ? method : "'#{method}'"
      end

    protected
      def options_for_ajax(options)
        js_options = build_callbacks(options)

        url_options = options[:url]
        url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
        js_options['url'] = "'#{url_for(url_options)}'"
        js_options['async'] = false if options[:type] == :synchronous
        js_options['type'] = options[:method] ? method_option_to_s(options[:method]) : ( options[:form] ? "'post'" : nil )
        js_options['dataType'] = options[:datatype] ? "'#{options[:datatype]}'" : (options[:update] ? "'html'" : "'script'")

        if options[:form]
          js_options['data'] = "#{JQUERY_VAR}.param(#{JQUERY_VAR}(this).serializeArray())"
        elsif options[:submit]
          js_options['data'] = "#{JQUERY_VAR}(\"##{options[:submit]}:input\").serialize()"
        elsif options[:with]
          js_options['data'] = options[:with].gsub("Form.serialize(this.form)","#{JQUERY_VAR}.param(#{JQUERY_VAR}(this.form).serializeArray())")
        end

        js_options['type'] ||= "'post'"
        if options[:method]
          if method_option_to_s(options[:method]) == "'put'" || method_option_to_s(options[:method]) == "'delete'"
            js_options['type'] = "'post'"
            if js_options['data']
              js_options['data'] << " + '&"
            else
              js_options['data'] = "'"
            end
            js_options['data'] << "_method=#{options[:method]}'"
          end
        end

        if USE_PROTECTION && respond_to?('protect_against_forgery?') && protect_against_forgery?
          if js_options['data']
            js_options['data'] << " + '&"
          else
            js_options['data'] = "'"
          end
          js_options['data'] << "#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
        end
        js_options['data'] = "''" if js_options['type'] == "'post'" && js_options['data'].nil?
        options_for_javascript(js_options.reject {|key, value| value.nil?})
      end

      def build_update_for_success(html_id, insertion=nil)
        insertion = build_insertion(insertion)
        "#{JQUERY_VAR}('#{jquery_id(html_id)}').#{insertion}(request);"
      end

      def build_update_for_error(html_id, insertion=nil)
        insertion = build_insertion(insertion)
        "#{JQUERY_VAR}('#{jquery_id(html_id)}').#{insertion}(request.responseText);"
      end

      def build_insertion(insertion)
        insertion = insertion ? insertion.to_s.downcase : 'html'
        insertion = 'append' if insertion == 'bottom'
        insertion = 'prepend' if insertion == 'top'
        insertion
      end

      def build_observer(name, options = {})
        if options[:with] && (options[:with] !~ /[\{=(.]/)
          options[:with] = "'#{options[:with]}=' + value"
        else
          options[:with] ||= 'value' unless options[:function]
        end

        callback = options[:function] || remote_function(options)
        javascript  = "#{JQUERY_VAR}('#{jquery_id(name)}').delayedObserver("
        javascript << "#{options[:frequency] || 0}, "
        javascript << "function(element, value) {"
        javascript << "#{callback}}"
        #javascript << ", '#{options[:on]}'" if options[:on]
        javascript << ")"
        javascript_tag(javascript)
      end

      def build_callbacks(options)
        callbacks = {}
        options[:beforeSend] = '';
        [:uninitialized,:loading].each do |key|
          options[:beforeSend] << (options[key].last == ';' ? options.delete(key) : options.delete(key) << ';') if options[key]
        end
        options.delete(:beforeSend) if options[:beforeSend].blank?
        options[:complete] = options.delete(:loaded) if options[:loaded]
        options[:error] = options.delete(:failure) if options[:failure]
        if options[:update]
          if options[:update].is_a?(Hash)
            options[:update][:error] = options[:update].delete(:failure) if options[:update][:failure]
            if options[:update][:success]
              options[:success] = build_update_for_success(options[:update][:success], options[:position]) << (options[:success] ? options[:success] : '')
            end
            if options[:update][:error]
              options[:error] = build_update_for_error(options[:update][:error], options[:position]) << (options[:error] ? options[:error] : '')
            end
          else
            options[:success] = build_update_for_success(options[:update], options[:position]) << (options[:success] ? options[:success] : '')
          end
        end
        options.each do |callback, code|
          if JQCALLBACKS.include?(callback)
            callbacks[callback] = "function(request){#{code}}"
          end
        end
        callbacks
      end

    end

  end
end
