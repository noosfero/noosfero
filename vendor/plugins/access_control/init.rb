require 'access_control'
require 'acts_as_accessor'
require 'acts_as_accessible'
require 'permission_name_helper'
require 'role'
require 'role_assignment'
require 'permission_check'

module ApplicationHelper
  include PermissionNameHelper
end
