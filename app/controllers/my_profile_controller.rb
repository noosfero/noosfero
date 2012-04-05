class MyProfileController < ApplicationController

  needs_profile


  before_filter :login_required

  # declares that the controller needs an specific type of profile. Example:
  #
  #  class PersonDetailControlles < ProfileAdminController
  #    requires_profile_class Person
  #  end
  #
  # The above controller will reject every request to it unless the current
  # profile (as indicated by the first URL component) is of class Person (or of
  # a subclass of Person) 
  def self.requires_profile_class(some_class)
    before_filter do |controller|
      unless controller.send(:profile).kind_of?(some_class)
        controller.send(:render_access_denied, _("This action is not available for \"%s\".") % controller.send(:profile).name)
      end
    end
  end

end
