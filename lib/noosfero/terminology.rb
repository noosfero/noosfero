module Noosfero
  class  Terminology

    def get(x)
      raise NotImplementedError
    end

    # the default terminology. Just returns the same message as is.
    class Default
      def get(x)
        x
      end
    end

    class Custom
      def initialize(hash)
        @messages = hash
      end
      def get(x)
        @messages[x] || x
      end
    end

  end
end
