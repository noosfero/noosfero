class ActsAsSolr::Post
  class << self
    alias_method :execute_orig, :execute
  end
end
module ActsAsSolr::ParserMethods
  alias_method :parse_results_orig, :parse_results
end

class TestSolr

  def self.enable
    ActsAsSolr::Post.class_eval do
      def self.execute(*args)
        execute_orig *args
      end
    end
    ActsAsSolr::ParserMethods.module_eval do
      def parse_results(*args)
        parse_results_orig *args
      end
    end

    # clear index
    ActsAsSolr::Post.execute(Solr::Request::Delete.new(:query => '*:*'))

    @solr_disabled = false
  end

  def self.disable
    return if @solr_disabled

    ActsAsSolr::Post.class_eval do
      def self.execute(*args)
        true
      end
    end
    ActsAsSolr::ParserMethods.module_eval do
      def parse_results(*args)
        parse_results_orig nil, args[1]
      end
    end

    @solr_disabled = true
  end

end

# disable solr actions by default
TestSolr.disable
