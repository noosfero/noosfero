module ActionView
  module Helpers

    # Converts chained method calls on DOM proxy elements into JavaScript chains
    # copied from rails 3.0.20
    class JavaScriptProxy < ActiveSupport::BasicObject #:nodoc:

      def initialize(generator, root = nil)
        @generator = generator
        @generator << root if root
      end

      def is_a?(klass)
        klass == JavaScriptProxy
      end

      private
      def method_missing(method, *arguments, &block)
        if method.to_s =~ /(.*)=$/
          assign($1, arguments.first)
        else
          call("#{method.to_s.camelize(:lower)}", *arguments, &block)
        end
      end

      def call(function, *arguments, &block)
        append_to_function_chain!("#{function}(#{@generator.send(:arguments_for_call, arguments, block)})")
        self
      end

      def assign(variable, value)
        append_to_function_chain!("#{variable} = #{@generator.send(:javascript_object_for, value)}")
      end

      def function_chain
        @function_chain ||= @generator.instance_variable_get(:@lines)
      end

      def append_to_function_chain!(call)
        function_chain[-1].chomp!(';')
        function_chain[-1] += ".#{call};"
      end
    end

    # copied from rails 3.0.20
    class JavaScriptCollectionProxy < JavaScriptProxy #:nodoc:
      ENUMERABLE_METHODS_WITH_RETURN = [:all, :any, :collect, :map, :detect, :find, :find_all, :select, :max, :min, :partition, :reject, :sort_by, :in_groups_of, :each_slice] unless defined? ENUMERABLE_METHODS_WITH_RETURN
      ENUMERABLE_METHODS = ENUMERABLE_METHODS_WITH_RETURN + [:each] unless defined? ENUMERABLE_METHODS
      attr_reader :generator
      delegate :arguments_for_call, :to => :generator

      def initialize(generator, pattern)
        super(generator, @pattern = pattern)
      end

      def each_slice(variable, number, &block)
        if block
          enumerate :eachSlice, :variable => variable, :method_args => [number], :yield_args => %w(value index), :return => true, &block
        else
          add_variable_assignment!(variable)
          append_enumerable_function!("eachSlice(#{::ActiveSupport::JSON.encode(number)});")
        end
      end

      def grep(variable, pattern, &block)
        enumerate :grep, :variable => variable, :return => true, :method_args => [::ActiveSupport::JSON::Variable.new(pattern.inspect)], :yield_args => %w(value index), &block
      end

      def in_groups_of(variable, number, fill_with = nil)
        arguments = [number]
        arguments << fill_with unless fill_with.nil?
        add_variable_assignment!(variable)
        append_enumerable_function!("inGroupsOf(#{arguments_for_call arguments});")
      end

      def inject(variable, memo, &block)
        enumerate :inject, :variable => variable, :method_args => [memo], :yield_args => %w(memo value index), :return => true, &block
      end

      def pluck(variable, property)
        add_variable_assignment!(variable)
        append_enumerable_function!("pluck(#{::ActiveSupport::JSON.encode(property)});")
      end

      def zip(variable, *arguments, &block)
        add_variable_assignment!(variable)
        append_enumerable_function!("zip(#{arguments_for_call arguments}")
        if block
          function_chain[-1] += ", function(array) {"
          yield ::ActiveSupport::JSON::Variable.new('array')
          add_return_statement!
          @generator << '});'
        else
          function_chain[-1] += ');'
        end
      end

      private
      def method_missing(method, *arguments, &block)
        if ENUMERABLE_METHODS.include?(method)
          returnable = ENUMERABLE_METHODS_WITH_RETURN.include?(method)
          enumerate(method, {:variable => (arguments.first if returnable), :return => returnable, :yield_args => %w(value index)}, &block)
        else
          super
        end
      end

      # Options
      #   * variable - name of the variable to set the result of the enumeration to
      #   * method_args - array of the javascript enumeration method args that occur before the function
      #   * yield_args - array of the javascript yield args
      #   * return - true if the enumeration should return the last statement
      def enumerate(enumerable, options = {}, &block)
        options[:method_args] ||= []
        options[:yield_args]  ||= []
        yield_args  = options[:yield_args] * ', '
        method_args = arguments_for_call options[:method_args] # foo, bar, function
        method_args << ', ' unless method_args.blank?
        add_variable_assignment!(options[:variable]) if options[:variable]
        append_enumerable_function!("#{enumerable.to_s.camelize(:lower)}(#{method_args}function(#{yield_args}) {")
        # only yield as many params as were passed in the block
        yield(*options[:yield_args].collect { |p| JavaScriptVariableProxy.new(@generator, p) }[0..block.arity-1])
        add_return_statement! if options[:return]
        @generator << '});'
      end

      def add_variable_assignment!(variable)
        function_chain.push("var #{variable} = #{function_chain.pop}")
      end

      def add_return_statement!
        unless function_chain.last =~ /return/
          function_chain.push("return #{function_chain.pop.chomp(';')};")
        end
      end

      def append_enumerable_function!(call)
        function_chain[-1].chomp!(';')
        function_chain[-1] += ".#{call}"
      end
    end

    class JavaScriptElementProxy < JavaScriptProxy #:nodoc:

      JQUERY_VAR = ::JRails::JQUERY_VAR

      def initialize(generator, id)
        id = id.to_s.count('#.*,>+~:[/ ') == 0 ? "##{id}" : id
        @id = id
        super(generator, "#{JQUERY_VAR}(\"#{id}\")")
      end

      def replace_html(*options_for_render)
        call 'html', @generator.send(:render, *options_for_render)
      end

      def replace(*options_for_render)
        call 'replaceWith', @generator.send(:render, *options_for_render)
      end

      def reload(options_for_replace={})
        replace(options_for_replace.merge({ :partial => @id.to_s.sub(/^#/,'') }))
      end

      def value()
        call 'val()'
      end

      def value=(value)
        call 'val', value
      end

    end

    class JavaScriptElementCollectionProxy < JavaScriptCollectionProxy #:nodoc:\

      JQUERY_VAR = ::JRails::JQUERY_VAR

      def initialize(generator, pattern)
        super(generator, "#{JQUERY_VAR}(#{pattern.to_json})")
      end
    end

  end
end
