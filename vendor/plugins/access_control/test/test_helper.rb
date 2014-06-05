ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
 
require 'test/unit'
require 'mocha'

# from Rails
require 'rails/test_help'

# load the database schema for the tests
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
load(File.dirname(__FILE__) + '/schema.rb')
# change the table names for the tests to not touch
Role.set_table_name 'access_control_test_roles'
RoleAssignment.set_table_name 'access_control_test_role_assignments'

# accessor example class to access some resources
class AccessControlTestAccessor < ActiveRecord::Base
  set_table_name 'access_control_test_accessors'
  acts_as_accessor
  attr_accessible :name
  def cache_keys(arg)
    []
  end
  def blocks_to_expire_cache
    []
  end
end

# resource example class to be accessed by some accessor
class AccessControlTestResource < ActiveRecord::Base
  set_table_name 'access_control_test_resources'
  acts_as_accessible  
  PERMISSIONS[self.class.name] = {'bla' => N_('Bla')}

  attr_accessible :name
end

# controller to test protection
class AccessControlTestController < ApplicationController
  include PermissionCheck
  protect 'see_index', 'global', :user,  :only => :index
  protect 'do_some_stuff', :resource, :user, :only => :other_stuff
  def index
     render :text => 'test controller'
  end

  def other_stuff
    render :text => 'test stuff'
  end

protected
  def user
    AccessControlTestAccessor.find(params[:user]) if params[:user]
  end

  def resource
    AccessControlTestResource.find(params[:resource]) if params[:resource]
  end
end
