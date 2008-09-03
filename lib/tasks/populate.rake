require File.dirname(__FILE__) + '/../../config/environment'
require 'noosfero'
require 'gettext/rails'
include GetText

namespace :db do
  desc "Populate database with basic required data to run application"
  task :populate do
    Environment.create!(:name => 'Noosfero', :is_default => true) unless (Environment.default)
    create_roles
    new_permissions
  end
end

def new_permissions
  admin = Profile::Roles.admin
  admin.permissions += ['manage_friends', 'validate_enterprise', 'perform_task']
  admin.save

  moderator = Profile::Roles.moderator
  moderator.permissions += ['manage_friends', 'perform_task']
  moderator.save
end

def create_roles
  # Environment administrator!
  Role.create!(:key => 'environment_administrator', :name => N_('Environment Administrator'), :permissions => [
    'view_environment_admin_panel',
    'edit_environment_features', 
    'edit_environment_design', 
    'manage_environment_categories', 
    'manage_environment_roles', 
    'manage_environment_validators',
    'edit_profile',
    'destroy_profile',
    'manage_memberships',
    'post_content',
    'edit_profile_design',
    'manage_products',
    'edit_appearance',
  ])
  Role.create!(:key => 'profile_admin', :name => N_('Profile Administrator'), :permissions => [
    'edit_profile',
    'destroy_profile',
    'manage_memberships',
    'post_content',
    'edit_profile_design',
    'manage_products',
    'edit_appearance',
  ])
  # members for enterprises, communities etc
  Role.create!(:key => "profile_member", :name => N_('Member'), :permissions => [
    'edit_profile', 
    'post_content', 
    'manage_products' 
  ])
  # moderators for enterprises, communities etc
  Role.create!(:key => 'profile_moderator', :name => N_('Moderator'), :permissions => [
    'manage_memberships', 
    'edit_profile_design', 
    'manage_products'
  ])
end

# vim: ft=ruby
