require_dependency File.dirname(__FILE__) + '/related_organizations_block'

class SubOrganizationsPlugin < Noosfero::Plugin; end;

require_dependency 'sub_organizations_plugin/search_helper'

class SubOrganizationsPlugin < Noosfero::Plugin

  include SearchHelper

  DISPLAY_LIMIT = 12

  def self.plugin_name
    _("Sub-groups")
  end

  def self.plugin_description
    _("Adds the ability for groups to have sub-groups.")
  end

  def control_panel_buttons
    if context.profile.organization? && Organization.parents(context.profile).blank?
      { :title => _('Manage sub-groups'), :icon => 'groups', :url => {:controller => 'sub_organizations_plugin_myprofile'} }
    end
  end

  def stylesheet?
    true
  end

  def organization_members(organization)
    children = Organization.children(organization)
    Person.members_of(children.all) if children.present?
  end

  def person_memberships(person)
    Organization.parents(*Profile.memberships_of(person))
  end

  def has_permission?(person, permission, target)
    if !target.kind_of?(Environment) && target.organization?
      Organization.parents(target).map do |parent|
        person.has_permission_without_plugins?(permission, parent)
      end.include?(true)
    end
  end

  def new_community_hidden_fields
    parent_to_be = context.params[:sub_organizations_plugin_parent_to_be]
    {'sub_organizations_plugin_parent_to_be' => parent_to_be} if parent_to_be.present?
  end

  def enterprise_registration_hidden_fields
    parent_to_be = context.params[:sub_organizations_plugin_parent_to_be]
    {'sub_organizations_plugin_parent_to_be' => parent_to_be} if parent_to_be.present?
  end

  def self.limit(organizations)
    organizations.limit(DISPLAY_LIMIT).order('updated_at DESC').sort_by{ rand }
  end

  def self.extra_blocks
    {
      RelatedOrganizationsBlock => {:type => [Enterprise, Community], :position => ['1', '2', '3']}
    }
  end
end
