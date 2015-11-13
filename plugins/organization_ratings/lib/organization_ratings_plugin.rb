class OrganizationRatingsPlugin < Noosfero::Plugin
  include Noosfero::Plugin::HotSpot

  def self.plugin_name
    "Organization Ratings"
  end

  def self.plugin_description
    _("A plugin that allows you to rate a organization and comment about it.")
  end

  module Hotspots
    def organization_ratings_plugin_comments_extra_fields
      nil
    end

    def organization_ratings_title
      nil
    end

    def organization_ratings_plugin_star_message
      nil
    end

    def organization_ratings_plugin_task_extra_fields user_rating
      nil
    end

    def organization_ratings_plugin_container_extra_fields user_rating
      nil
    end

    def organization_ratings_plugin_rating_created rating, params
      nil
    end
  end

  # Plugin Hotspot to display the average rating
  def display_organization_average_rating organization
    unless organization.nil?
      average_rating = OrganizationRating.average_rating organization.id

      Proc::new {
        render :file => 'blocks/display_organization_average_rating',
               :locals => {
                 :profile_identifier => organization.identifier,
                 :average_rating => average_rating
               }
      }
    end
  end

  def more_comments_count owner
    if owner.kind_of?(Environment) then
      owner.profiles.sum(:comments_count)
    elsif owner.kind_of?(Profile) then
      owner.comments_count
    else
      0
    end
  end

  def self.extra_blocks
    {
      OrganizationRatingsBlock => {:type => [Enterprise, Community], :position => ['1']},
      AverageRatingBlock => {:type => [Enterprise, Community]}
    }
  end

  def stylesheet?
    true
  end

  def js_files
    %w(
      public/rate.js
      public/organization_rating_management.js
    )
  end

end
