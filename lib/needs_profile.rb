module NeedsProfile

  module ClassMethods
    def needs_profile
      before_filter :load_profile
    end
  end

  def self.included(including)
    including.send(:extend, NeedsProfile::ClassMethods)
  end

  def boxes_holder
    profile || environment # prefers profile, but defaults to environment
  end

  protected 

  def profile
    @profile
  end

end
