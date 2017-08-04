module Api
  module Entities

    PERMISSIONS = {
      :admin => 0,
      :self  => 10,
      :private_content => 20,
      :logged_user => 30,
      :anonymous => 40
    }

    def self.can_display_profile_field? profile, options, permission_options={}
      permissions={:field => "", :permission => :private_content}
      permissions.merge!(permission_options)
      field = permissions[:field]
      permission = permissions[:permission]
      return true if profile.public? && profile.public_fields.map{|f| f.to_sym}.include?(field.to_sym)

      current_person = options[:current_person]

      current_permission = if current_person.present?
        if current_person.is_admin?
          :admin
        elsif current_person == profile
          :self
        elsif profile.display_private_info_to?(current_person)
          :private_content
        else
          :logged_user
        end
      else
        :anonymous
      end
      PERMISSIONS[current_permission] <= PERMISSIONS[permission]
    end

    def self.expose_optional_field?(field, options = {})
      return false if options[:params].nil?
      optional_fields = options[:params][:optional_fields] || []
      optional_fields.include?(field.to_s)
    end


    class Image < Entity
      expose :id
      expose :filename
      expose  :url do |image, options|
        image.public_filename
      end

      expose  :icon_url do |image, options|
        image.public_filename(:icon)
      end

      expose  :minor_url do |image, options|
        image.public_filename(:minor)
      end

      expose  :portrait_url do |image, options|
        image.public_filename(:portrait)
      end

      expose  :thumb_url do |image, options|
        image.public_filename(:thumb)
      end
    end

    class CategoryBase < Entity
      expose :name, :id, :slug
    end

    class Category < CategoryBase
      expose :full_name do |category, options|
        category.full_name
      end
      expose :parent, :using => CategoryBase, if: { parent: true }
      expose :children, :using => CategoryBase, if: { children: true }
      expose :image, :using => Image
      expose :display_color 
    end

    class Region < Category
      expose :parent_id
    end

    class BlockDefinition < Entity
      expose :description
      expose :short_description
      expose :pretty_name, as: :name
      expose :name, as: :type
    end

    class Block < Entity
      expose :id, :type, :settings, :position, :enabled
      expose :mirror, :mirror_block_id, :title
      expose :api_content, if: lambda { |object, options| options[:display_api_content] || object.display_api_content_by_default? } do |block, options|
        block.api_content({:current_person => options[:current_person]}.merge(options[:api_content_params] || {}))
      end
      expose :permissions do |block, options|
        Entities.permissions_for_entity(block, options[:current_person], :allow_edit?)
      end
      expose :images, :using => Image
      expose :definition do |block, options|
        BlockDefinition.represent(block.class)
      end
    end

    class Box < Entity
      expose :id, :position
      expose :blocks, :using => Block do |box, options|
        box.blocks.select {|block| block.visible_to_user?(options[:current_person]) || block.allow_edit?(options[:current_person]) }
      end
    end

    class Profile < Entity
      expose :identifier, :name, :id
      expose :created_at
      expose :updated_at

      expose :additional_data do |profile, options|
        hash = {}
        profile.environment.send("all_custom_#{profile.type.downcase}_fields").each  do |field, settings|
          if settings['active'].to_s == 'true'
            field_privacy = profile.fields_privacy[field] || profile.fields_privacy[field.to_sym]
            value = field_privacy == 'public' ? :anonymous : :private_content
            if Entities.can_display_profile_field?(profile, options, { :field => field, permission: value })
              hash[field] = profile.send('custom_field_value', field)
            end
          end    
        end  

        hash

      end
      expose :image, :using => Image
      expose :top_image, :using => Image
      expose :region, :using => Region
      expose :tag_list
      expose :type
      expose :custom_header
      expose :custom_footer
      expose :layout_template
      expose :permissions do |profile, options|
        Entities.permissions_for_entity(profile, options[:current_person],
        :allow_post_content?, :allow_edit?, :allow_destroy?, :allow_edit_design?)
      end
      expose :theme do |profile, options|
        profile.theme || profile.environment.theme
      end
      expose :boxes, :using => Box, :if => lambda {|profile, options| Entities.expose_optional_field?(:boxes, options)}

    end

    class UserBasic < Entity
      expose :id
      expose :login
    end

    class Person < Profile
      expose :user, :using => UserBasic, documentation: {type: 'User', desc: 'The user data of a person' }
      expose :vote_count

      attrs = [:email, :country, :state, :city, :nationality, :formation, :schooling]
      attrs.each do |attribute|
        name = attribute
        expose attribute, :as => name, :if => lambda{|person,options| Entities.can_display_profile_field?(person, options, {:field =>  attribute})}
      end

      expose :comments_count do |person, options|
        person.comments.count
      end
      expose :following_articles_count do |person, options|
        person.following_articles.count
      end
      expose :articles_count do |person, options|
        person.articles.count
      end
      expose :friends_count do |person, options|
        person.friends.size
      end
    end

    class Enterprise < Profile
    end

    class Community < Profile
      expose :description
      expose :admins, :if => lambda { |community, options| community.display_info_to? options[:current_person]} do |community, options|
        community.admins.map{|admin| {"name"=>admin.name, "id"=>admin.id, "username" => admin.identifier}}
      end
      expose :categories, :using => Category
      expose :members_count, :closed
      expose :members, :if => lambda {|community, options| Entities.expose_optional_field?(:members, options)}
    end

    class CommentBase < Entity
      expose :body, :title, :id
      expose :created_at
      expose :author, :using => Profile
      expose :reply_of, :using => CommentBase
      expose :permissions do |comment, options|
        Entities.permissions_for_entity(comment, options[:current_person],
        :allow_destroy?)
      end
    end

    class Comment < CommentBase
      expose :children, as: :replies, :using => Comment
    end

    class ArticleBase < Entity
      expose :id
      expose :body
      expose :abstract, documentation: {type: 'String', desc: 'Teaser of the body'}
      expose :created_at
      expose :updated_at
      expose :title, :documentation => {:type => "String", :desc => "Title of the article"}
      expose :created_by, :as => :author, :using => Profile, :documentation => {type: 'Profile', desc: 'The profile author that create the article'}
      expose :profile, :using => Profile, :documentation => {type: 'Profile', desc: 'The profile associated with the article'}
      expose :categories, :using => Category
      expose :image, :using => Image
      expose :votes_for
      expose :votes_against
      expose :setting
      expose :position
      expose :hits
      expose :start_date
      expose :end_date, :documentation => {type: 'DateTime', desc: 'The date of finish of the article'}
      expose :tag_list
      expose :children_count
      expose :slug, :documentation => {:type => "String", :desc => "Trimmed and parsed name of a article"}
      expose :path
      expose :followers_count
      expose :votes_count
      expose :comments_count
      expose :archived, :documentation => {:type => "Boolean", :desc => "Defines if a article is readonly"}
      expose :type
      expose :comments, using: CommentBase, :if => lambda{|comment,options| Entities.expose_optional_field?(:comments, options)}
      expose :published
      expose :accept_comments?, as: :accept_comments
      expose :mime_type
      expose :size, :if => lambda { |article, options| article.kind_of?(UploadedFile)}
      expose :name
      expose :public_filename, :if => lambda { |article, options| article.kind_of?(UploadedFile)}
    end

    def self.permissions_for_entity(entity, current_person, *method_names)
      method_names.map { |method| entity.send(method, current_person) ? method.to_s.gsub(/\?/,'') : nil }.compact
    end

    class Article < ArticleBase
      expose :parent, :using => ArticleBase
      expose :children, :using => ArticleBase do |article, options|
        article.children.published.limit(V1::Articles::MAX_PER_PAGE)
      end
      expose :permissions do |article, options|
        Entities.permissions_for_entity(article, options[:current_person],
          :allow_edit?, :allow_post_content?, :allow_delete?, :allow_create?,
          :allow_publish_content?)
      end
    end

    class User < Entity
      attrs = [:id,:login,:email,:activated?]
      aliases = {:activated? => :activated}

      attrs.each do |attribute|
        name = aliases.has_key?(attribute) ? aliases[attribute] : attribute
        expose attribute, :as => name, :if => lambda{|user,options| Entities.can_display_profile_field?(user.person, options, {:field =>  attribute})}
      end

      expose :person, :using => Person, :if => lambda{|user,options| user.person.display_info_to? options[:current_person]}
      expose :permissions, :if => lambda{|user,options| Entities.can_display_profile_field?(user.person, options, {:field => :permissions, :permission => :self})} do |user, options|
        output = {}
        user.person.role_assignments.map do |role_assigment|
          if role_assigment.resource.respond_to?(:identifier) && !role_assigment.role.nil?
            output[role_assigment.resource.identifier] = role_assigment.role.permissions
          end
        end
        output
      end
    end

    class UserLogin < User
      expose :private_token, documentation: {type: 'String', desc: 'A valid authentication code for post/delete api actions'}, if: lambda {|object, options| object.activated? }
    end

    class Task < Entity
      expose :id
      expose :type
      expose :requestor, using: Profile
      expose :status
      expose :created_at
      expose :data
      expose :accept_details
      expose :reject_details
      expose :accept_disabled?, as: :accept_disabled
      expose :reject_disabled?, as: :reject_disabled
      expose :target do |task, options|
        type_map = {Profile => ::Profile, Environment => ::Environment}.find {|h| task.target.kind_of?(h.last)}
        type_map.first.represent(task.target) unless type_map.nil?
      end
    end

    class Environment < Entity
      expose :name
      expose :id
      expose :description
      expose :layout_template
      expose :signup_intro
      expose :terms_of_use
      expose :top_url, as: :host
      expose :type do |environment, options|
        "Environment"
      end
      expose :settings, if: lambda { |instance, options| options[:is_admin] }
      expose :permissions, if: lambda { |environment, options| options[:current_person].present? } do |environment, options|
        environment.permissions_for(options[:current_person])
      end
      expose :theme
    end

    class Tag < Entity
      expose :name
      expose :taggings_count, as: :count
    end

    class Activity < Entity
      expose :id, :created_at, :updated_at
      expose :user, :using => Profile

      expose :target do |activity, opts|
        type_map = {Profile => ::Profile, ArticleBase => ::Article}.find {|h| activity.target.kind_of?(h.last)}
        type_map.first.represent(activity.target) unless type_map.nil?
      end
      expose :params, :if => lambda { |activity, options| activity.kind_of?(ActionTracker::Record)}
      expose :content, :if => lambda { |activity, options| activity.kind_of?(Scrap)}
      expose :verb do |activity, options|
        activity.kind_of?(Scrap) ? 'leave_scrap' : activity.verb
      end

    end

    class Role < Entity
      expose :id
      expose :name
      expose :key
      expose :assigned do |role, options|
        (options[:person_roles] || []).include?(role)
      end
    end

    class AbuseReport < Entity
      expose :id
      expose :reporter, using: Person
      expose :reason
      expose :created_at
    end

    class AbuseComplaint < Task
      expose :abuse_reports, using: AbuseReport
    end

    class Domain < Entity
      expose :id
      expose :name
      expose :is_default
      expose :owner do |domain, options|
        type_map = {Profile => ::Profile, Environment => ::Environment}.find {|k,v| domain.owner.kind_of?(v)}
        type_map.first.represent(domain.owner, options) unless type_map.nil?
      end
    end

    class Response < Entity
      expose :success
      expose :code
      expose :message
    end

    class Setting < Entity
      expose :available_blocks, :using => BlockDefinition
    end

  end
end
