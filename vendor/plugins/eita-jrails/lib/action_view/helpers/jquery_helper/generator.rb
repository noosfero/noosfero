module ActionView
  module Helpers
    module JqueryHelper

      class JavaScriptGenerator

        def initialize(context, &block) #:nodoc:
          @context, @lines = context, []
          def @lines.encoding() last.to_s.encoding end
          include_helpers_from_context
          @context.with_output_buffer(@lines) do
            @context.instance_exec(self, &block)
          end
        end

        private
        def include_helpers_from_context
          extend @context.controller._helpers if @context.controller.respond_to?(:_helpers) && @context.controller._helpers
          extend GeneratorMethods
        end

        module GeneratorMethods
          def to_s #:nodoc:
            (@lines * $/).tap do |javascript|
              if ActionView::Base.debug_rjs
                source = javascript.dup
                javascript.replace "try {\n#{source}\n} catch (e) "
                javascript << "{ alert('RJS error:\\n\\n' + e.toString()); alert('#{source.gsub('\\','\0\0').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }}'); throw e }"
              end
            end
          end

          # Returns a element reference by finding it through +id+ in the DOM. This element can then be
          # used for further method calls. Examples:
          #
          #   page['blank_slate']                  # => $('blank_slate');
          #   page['blank_slate'].show             # => $('blank_slate').show();
          #   page['blank_slate'].show('first').up # => $('blank_slate').show('first').up();
          #
          # You can also pass in a record, which will use ActionController::RecordIdentifier.dom_id to lookup
          # the correct id:
          #
          #   page[@post]     # => $('post_45')
          #   page[Post.new]  # => $('new_post')
          def [](id)
            case id
              when String, Symbol, NilClass
                JavaScriptElementProxy.new(self, id)
              else
                JavaScriptElementProxy.new(self, RecordIdentifier.dom_id(id))
            end
          end

          RecordIdentifier =
            if defined? ActionView::RecordIdentifier
              ActionView::RecordIdentifier
            else
              ActionController::RecordIdentifier
            end

          # Returns an object whose <tt>to_json</tt> evaluates to +code+. Use this to pass a literal JavaScript
          # expression as an argument to another JavaScriptGenerator method.
          def literal(code)
            JsonLiteral.new(code.to_s)
          end

          # Returns a collection reference by finding it through a CSS +pattern+ in the DOM. This collection can then be
          # used for further method calls. Examples:
          #
          #   page.select('p')                      # => $$('p');
          #   page.select('p.welcome b').first      # => $$('p.welcome b').first();
          #   page.select('p.welcome b').first.hide # => $$('p.welcome b').first().hide();
          #
          # You can also use prototype enumerations with the collection.  Observe:
          #
          #   # Generates: $$('#items li').each(function(value) { value.hide(); });
          #   page.select('#items li').each do |value|
          #     value.hide
          #   end
          #
          # Though you can call the block param anything you want, they are always rendered in the
          # javascript as 'value, index.'  Other enumerations, like collect() return the last statement:
          #
          #   # Generates: var hidden = $$('#items li').collect(function(value, index) { return value.hide(); });
          #   page.select('#items li').collect('hidden') do |item|
          #     item.hide
          #   end
          #
          def select(pattern)
            JavaScriptElementCollectionProxy.new(self, pattern)
          end

          # Inserts HTML at the specified +position+ relative to the DOM element
          # identified by the given +id+.
          #
          # +position+ may be one of:
          #
          # <tt>:top</tt>::    HTML is inserted inside the element, before the
          #                    element's existing content.
          # <tt>:bottom</tt>:: HTML is inserted inside the element, after the
          #                    element's existing content.
          # <tt>:before</tt>:: HTML is inserted immediately preceding the element.
          # <tt>:after</tt>::  HTML is inserted immediately following the element.
          #
          # +options_for_render+ may be either a string of HTML to insert, or a hash
          # of options to be passed to ActionView::Base#render.  For example:
          #
          #   # Insert the rendered 'navigation' partial just before the DOM
          #   # element with ID 'content'.
          #   # Generates: Element.insert("content", { before: "-- Contents of 'navigation' partial --" });
          #   page.insert_html :before, 'content', :partial => 'navigation'
          #
          #   # Add a list item to the bottom of the <ul> with ID 'list'.
          #   # Generates: Element.insert("list", { bottom: "<li>Last item</li>" });
          #   page.insert_html :bottom, 'list', '<li>Last item</li>'
          #
          def insert_html(position, id, *options_for_render)
            insertion = position.to_s.downcase
            insertion = 'append' if insertion == 'bottom'
            insertion = 'prepend' if insertion == 'top'
            call "#{JQUERY_VAR}(\"#{jquery_id(id)}\").#{insertion}", render(*options_for_render)
          end

          # Replaces the inner HTML of the DOM element with the given +id+.
          #
          # +options_for_render+ may be either a string of HTML to insert, or a hash
          # of options to be passed to ActionView::Base#render.  For example:
          #
          #   # Replace the HTML of the DOM element having ID 'person-45' with the
          #   # 'person' partial for the appropriate object.
          #   # Generates:  Element.update("person-45", "-- Contents of 'person' partial --");
          #   page.replace_html 'person-45', :partial => 'person', :object => @person
          #
          def replace_html(id, *options_for_render)
            insert_html(:html, id, *options_for_render)
          end

          # Replaces the "outer HTML" (i.e., the entire element, not just its
          # contents) of the DOM element with the given +id+.
          #
          # +options_for_render+ may be either a string of HTML to insert, or a hash
          # of options to be passed to ActionView::Base#render.  For example:
          #
          #   # Replace the DOM element having ID 'person-45' with the
          #   # 'person' partial for the appropriate object.
          #   page.replace 'person-45', :partial => 'person', :object => @person
          #
          # This allows the same partial that is used for the +insert_html+ to
          # be also used for the input to +replace+ without resorting to
          # the use of wrapper elements.
          #
          # Examples:
          #
          #   <div id="people">
          #     <%= render :partial => 'person', :collection => @people %>
          #   </div>
          #
          #   # Insert a new person
          #   #
          #   # Generates: new Insertion.Bottom({object: "Matz", partial: "person"}, "");
          #   page.insert_html :bottom, :partial => 'person', :object => @person
          #
          #   # Replace an existing person
          #
          #   # Generates: Element.replace("person_45", "-- Contents of partial --");
          #   page.replace 'person_45', :partial => 'person', :object => @person
          #
          def replace(id, *options_for_render)
            call "#{JQUERY_VAR}(\"#{jquery_id(id)}\").replaceWith", render(*options_for_render)
          end

          # Removes the DOM elements with the given +ids+ from the page.
          #
          # Example:
          #
          #  # Remove a few people
          #  # Generates: ["person_23", "person_9", "person_2"].each(Element.remove);
          #  page.remove 'person_23', 'person_9', 'person_2'
          #
          def remove(*ids)
            call "#{JQUERY_VAR}(\"#{jquery_ids(ids)}\").remove"
          end

          # Shows hidden DOM elements with the given +ids+.
          #
          # Example:
          #
          #  # Show a few people
          #  # Generates: ["person_6", "person_13", "person_223"].each(Element.show);
          #  page.show 'person_6', 'person_13', 'person_223'
          #
          def show(*ids)
            call "#{JQUERY_VAR}(\"#{jquery_ids(ids)}\").show"
          end

          # Hides the visible DOM elements with the given +ids+.
          #
          # Example:
          #
          #  # Hide a few people
          #  # Generates: ["person_29", "person_9", "person_0"].each(Element.hide);
          #  page.hide 'person_29', 'person_9', 'person_0'
          #
          def hide(*ids)
            call "#{JQUERY_VAR}(\"#{jquery_ids(ids)}\").hide"
          end

          # Hides the visible DOM elements with the given +ids+.
          #
          # Example:
          #
          #  # Hide a few people
          #  # Generates: ["person_29", "person_9", "person_0"].each(Element.hide);
          #  page.hide 'person_29', 'person_9', 'person_0'
          #
          def toggle(*ids)
            call "#{JQUERY_VAR}(\"#{jquery_ids(ids)}\").toggle"
          end

          # Redirects the browser to the given +location+ using JavaScript, in the same form as +url_for+.
          #
          # Examples:
          #
          #  # Generates: window.location.href = "/mycontroller";
          #  page.redirect_to(:action => 'index')
          #
          #  # Generates: window.location.href = "/account/signup";
          #  page.redirect_to(:controller => 'account', :action => 'signup')
          def redirect_to(location)
            url = location.is_a?(String) ? location : @context.url_for(location)
            record "window.location.href = #{url.inspect}"
          end

          # Starts a script.aculo.us visual effect. See
          # ActionView::Helpers::ScriptaculousHelper for more information.
          def visual_effect(name, id = nil, options = {})
            record @context.send(:visual_effect, name, id, options)
          end

          # Creates a script.aculo.us sortable element. Useful
          # to recreate sortable elements after items get added
          # or deleted.
          # See ActionView::Helpers::ScriptaculousHelper for more information.
          def sortable(id, options = {})
            record @context.send(:sortable_element_js, id, options)
          end

          # Creates a script.aculo.us draggable element.
          # See ActionView::Helpers::ScriptaculousHelper for more information.
          def draggable(id, options = {})
            record @context.send(:draggable_element_js, id, options)
          end

          # Creates a script.aculo.us drop receiving element.
          # See ActionView::Helpers::ScriptaculousHelper for more information.
          def drop_receiving(id, options = {})
            record @context.send(:drop_receiving_element_js, id, options)
          end

          # Reloads the browser's current +location+ using JavaScript
          #
          # Examples:
          #
          #  # Generates: window.location.reload();
          #  page.reload
          def reload
            record 'window.location.reload()'
          end

          # Calls the JavaScript +function+, optionally with the given +arguments+.
          #
          # If a block is given, the block will be passed to a new JavaScriptGenerator;
          # the resulting JavaScript code will then be wrapped inside <tt>function() { ... }</tt>
          # and passed as the called function's final argument.
          #
          # Examples:
          #
          #   # Generates: Element.replace(my_element, "My content to replace with.")
          #   page.call 'Element.replace', 'my_element', "My content to replace with."
          #
          #   # Generates: alert('My message!')
          #   page.call 'alert', 'My message!'
          #
          #   # Generates:
          #   #     my_method(function() {
          #   #       $("one").show();
          #   #       $("two").hide();
          #   #    });
          #   page.call(:my_method) do |p|
          #      p[:one].show
          #      p[:two].hide
          #   end
          def call(function, *arguments, &block)
            record "#{function}(#{arguments_for_call(arguments, block)})"
          end

          # Assigns the JavaScript +variable+ the given +value+.
          #
          # Examples:
          #
          #  # Generates: my_string = "This is mine!";
          #  page.assign 'my_string', 'This is mine!'
          #
          #  # Generates: record_count = 33;
          #  page.assign 'record_count', 33
          #
          #  # Generates: tabulated_total = 47
          #  page.assign 'tabulated_total', @total_from_cart
          #
          def assign(variable, value)
            record "#{variable} = #{javascript_object_for(value)}"
          end

          # Writes raw JavaScript to the page.
          #
          # Example:
          #
          #  page << "alert('JavaScript with Prototype.');"
          def <<(javascript)
            @lines << javascript
          end

          # Executes the content of the block after a delay of +seconds+. Example:
          #
          #   # Generates:
          #   #     setTimeout(function() {
          #   #     ;
          #   #     new Effect.Fade("notice",{});
          #   #     }, 20000);
          #   page.delay(20) do
          #     page.visual_effect :fade, 'notice'
          #   end
          def delay(seconds = 1)
            record "setTimeout(function() {\n\n"
            yield
            record "}, #{(seconds * 1000).to_i})"
          end

          def javascript_object_for(object)
            ::ActiveSupport::JSON.encode(object)
          end

          def arguments_for_call(arguments, block = nil)
            arguments << block_to_function(block) if block
            arguments.map { |argument| javascript_object_for(argument) }.join ', '
          end

          private

          def jquery_id(id)
            id.to_s.count('#.*,>+~:[/ ') == 0 ? "##{id}" : id
          end

          def jquery_ids(ids)
            Array(ids).map{|id| jquery_id(id)}.join(',')
          end

          def loop_on_multiple_args(method, ids)
            record(ids.size>1 ?
                   "#{javascript_object_for(ids)}.each(#{method})" :
                   "#{method}(#{javascript_object_for(ids.first)})")
          end

          def page
            self
          end

          def record(line)
            line = "#{line.to_s.chomp.gsub(/\;\z/, '')};"
            self << line
            line
          end

          def render(*options)
            with_formats(:html) do
              case option = options.first
              when Hash
                @context.render(*options)
              else
                option.to_s
              end
            end
          end

          def with_formats(*args)
            return yield unless @context

            lookup = @context.lookup_context
            begin
              old_formats, lookup.formats = lookup.formats, args
              yield
            ensure
              lookup.formats = old_formats
            end
          end

          def block_to_function(block)
            generator = self.class.new(@context, &block)
            literal("function() { #{generator.to_s} }")
          end

          def method_missing(method, *arguments)
            JavaScriptProxy.new(self, method.to_s.camelize)
          end
        end
      end

    end
  end
end
