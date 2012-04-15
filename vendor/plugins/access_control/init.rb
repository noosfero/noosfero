require 'acts_as_accessor'
require 'acts_as_accessible'
require 'permission_name_helper'
module ApplicationHelper
  include PermissionNameHelper
end
