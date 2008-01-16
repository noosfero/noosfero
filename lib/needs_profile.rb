module NeedsProfile

  module ClassMethods
    def needs_profile
      before_filter :load_profile
      def boxes_holder
        profile
      end
    end
  end

  def self.included(including)
    including.send(:extend, NeedsProfile::ClassMethods)
  end

  protected 

  def profile
    @profile
  end

end
