
module ActionView
  module Helpers

    module JqueryUiHelper

      JQUERY_VAR = ::JRails::JQUERY_VAR

      SCRIPTACULOUS_EFFECTS = {
        appear: {method: 'fadeIn'},
        blind_down: {method: 'blind', mode: 'show', options: {direction: 'vertical'}},
        blind_up: {method: 'blind', mode: 'hide', options: {direction: 'vertical'}},
        blind_right: {method: 'blind', mode: 'show', options: {direction: 'horizontal'}},
        blind_left: {method: 'blind', mode: 'hide', options: {direction: 'horizontal'}},
        bounce_in: {method: 'bounce', mode: 'show', options: {direction: 'up'}},
        bounce_out: {method: 'bounce', mode: 'hide', options: {direction: 'up'}},
        drop_in: {method: 'drop', mode: 'show', options: {direction: 'up'}},
        drop_out: {method: 'drop', mode: 'hide', options: {direction: 'down'}},
        fade: {method: 'fadeOut'},
        fold_in: {method: 'fold', mode: 'hide'},
        fold_out: {method: 'fold', mode: 'show'},
        grow: {method: 'scale', mode: 'show'},
        shrink: {method: 'scale', mode: 'hide'},
        slide_down: {method: 'slide', mode: 'show', options: {direction: 'up'}},
        slide_up: {method: 'slide', mode: 'hide', options: {direction: 'up'}},
        slide_right: {method: 'slide', mode: 'show', options: {direction: 'left'}},
        slide_left: {method: 'slide', mode: 'hide', options: {direction: 'left'}},
        squish: {method: 'scale', mode: 'hide', options: {origin: "['top','left']"}},
        switch_on: {method: 'clip', mode: 'show', options: {direction: 'vertical'}},
        switch_off: {method: 'clip', mode: 'hide', options: {direction: 'vertical'}},
        toggle_appear: {method: 'fadeToggle'},
        toggle_slide: {method: 'slide', mode: 'toggle', options: {direction: 'up'}},
        toggle_blind: {method: 'blind', mode: 'toggle', options: {direction: 'vertical'}},
      }

      def visual_effect(name, element_id = false, js_options = {})
        if SCRIPTACULOUS_EFFECTS.has_key? name.to_sym
          effect = SCRIPTACULOUS_EFFECTS[name.to_sym]
          name = effect[:method]
          mode = effect[:mode]
          js_options = js_options.merge(effect[:options]) if effect[:options]
        end

        [:color, :direction, :startcolor, :endcolor].each do |option|
          js_options[option] = "'#{js_options[option]}'" if js_options[option]
        end

        if js_options.has_key? :duration
          speed = js_options.delete :duration
          speed = (speed * 1000).to_i unless speed.nil?
        else
          speed = js_options.delete :speed
        end

        if %w[fadeIn fadeOut fadeToggle].include? name
          javascript = "#{JQUERY_VAR}(\"#{jquery_id(element_id)}\").#{name}("
          javascript << "#{speed}" unless speed.nil?
          javascript << ");"
        else
          javascript = "#{JQUERY_VAR}(\"#{jquery_id(element_id)}\").#{mode || 'effect'}('#{name}'"
          javascript << ",#{options_for_javascript(js_options)}" unless speed.nil? && js_options.empty?
          javascript << ",#{speed}" unless speed.nil?
          javascript << ");"
        end

      end

      def sortable_element(element_id, options = {})
        javascript_tag(sortable_element_js(element_id, options).chop!)
      end

      def sortable_element_js(element_id, options = {}) #:nodoc:
        #convert similar attributes
        options[:handle] = ".#{options[:handle]}" if options[:handle]
        if options[:tag] || options[:only]
          options[:items] = "> "
          options[:items] << options.delete(:tag) if options[:tag]
          options[:items] << ".#{options.delete(:only)}" if options[:only]
        end
        options[:connectWith] = options.delete(:containment).map {|x| "##{x}"} if options[:containment]
        options[:containment] = options.delete(:container) if options[:container]
        options[:dropOnEmpty] = false unless options[:dropOnEmpty]
        options[:helper] = "'clone'" if options[:ghosting] == true
        options[:axis] = case options.delete(:constraint)
          when "vertical", :vertical
            "y"
          when "horizontal", :horizontal
            "x"
          when false
            nil
          when nil
            "y"
        end
        options.delete(:axis) if options[:axis].nil?
        options.delete(:overlap)
        options.delete(:ghosting)

        if options[:onUpdate] || options[:url]
          if options[:format]
            options[:with] ||= "#{JQUERY_VAR}(this).sortable('serialize',{key:'#{element_id}[]', expression:#{options[:format]}})"
            options.delete(:format)
          else
            options[:with] ||= "#{JQUERY_VAR}(this).sortable('serialize',{key:'#{element_id}[]'})"
          end

          options[:onUpdate] ||= "function(){" + remote_function(options) + "}"
        end

        options.delete_if { |key, value| JqueryHelper::AJAX_OPTIONS.include?(key) }
        options[:update] = options.delete(:onUpdate) if options[:onUpdate]

        [:axis, :cancel, :containment, :cursor, :handle, :tolerance, :items, :placeholder].each do |option|
          options[option] = "'#{options[option]}'" if options[option]
        end

        options[:connectWith] = array_or_string_for_javascript(options[:connectWith]) if options[:connectWith]

        %(#{JQUERY_VAR}('#{jquery_id(element_id)}').sortable(#{options_for_javascript(options)});)
      end

      def draggable_element(element_id, options = {})
        javascript_tag(draggable_element_js(element_id, options).chop!)
      end

      def draggable_element_js(element_id, options = {})
        %(#{JQUERY_VAR}("#{jquery_id(element_id)}").draggable(#{options_for_javascript(options)});)
      end

      def drop_receiving_element(element_id, options = {})
        javascript_tag(drop_receiving_element_js(element_id, options).chop!)
      end

      def drop_receiving_element_js(element_id, options = {})
        #convert similar options
        options[:hoverClass] = options.delete(:hoverclass) if options[:hoverclass]
        options[:drop] = options.delete(:onDrop) if options[:onDrop]

        if options[:drop] || options[:url]
          options[:with] ||= "'id=' + encodeURIComponent(#{JQUERY_VAR}(ui.draggable).attr('id'))"
          options[:drop] ||= "function(ev, ui){" + remote_function(options) + "}"
        end

        options.delete_if { |key, value| JqueryHelper::AJAX_OPTIONS.include?(key) }

        options[:accept] = array_or_string_for_javascript(options[:accept]) if options[:accept]
        [:activeClass, :hoverClass, :tolerance].each do |option|
          options[option] = "'#{options[option]}'" if options[option]
        end

        %(#{JQUERY_VAR}('#{jquery_id(element_id)}').droppable(#{options_for_javascript(options)});)
      end

      def array_or_string_for_javascript(option)
        if option.kind_of?(Array)
          "['#{option.join('\',\'')}']"
        elsif !option.nil?
          "'#{option}'"
        end
      end

    end

  end
end
