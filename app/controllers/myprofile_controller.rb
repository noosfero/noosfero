class MyProfileController < ApplicationController

  needs_profile

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
        controller.instance_variable_set('@message',  _("This action is not available for \"%s\".") % controller.send(:profile).name)
        controller.render :file => File.join(RAILS_ROOT, 'app', 'views', 'shared', 'access_denied.rhtml'), :layout => true, :status => 403
      end
    end
  end

end
