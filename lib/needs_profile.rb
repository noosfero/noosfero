module NeedsProfile

  module ClassMethods
    def needs_profile
      before_filter :load_profile
      design :holder => 'profile' 
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
