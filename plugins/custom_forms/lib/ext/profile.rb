require_dependency 'profile'

class Profile

  has_many :forms, :class_name => 'CustomFormsPlugin::Form', :dependent => :destroy

end
