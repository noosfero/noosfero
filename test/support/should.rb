
module Test

  module Should

    def should name, &block
      @shoulds ||= []

      destname = 'test_should_' + name.gsub(/[^a-zA-z0-9]+/, '_')
      if @shoulds.include?(destname)
        raise "there is already a test named \"#{destname}\""
      end

      @shoulds << destname
      if block_given?
        self.send(:define_method, destname, &block)
      else
        self.send(:define_method, destname) do
          flunk 'pending: should ' + name
        end
      end

    end

  end

end
