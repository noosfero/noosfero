
class OpenGraphPlugin::Stories

  class_attribute :publishers
  self.publishers = []

  def self.register_publisher publisher
    self.publishers << publisher
  end

  def self.publish record, stories
    actor = User.current.person rescue nil
    return unless actor

    self.publishers.each do |publisher|
      publisher = publisher.delay unless Rails.env.development? or Rails.env.test?
      publisher.publish_stories record, actor, stories
    end
  end

  Definitions = {
    # needed a patch on UploadedFile: def notifiable?; true; end
    add_a_document: {
      action_tracker_verb: :create_article,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :add,
      object_type: :uploaded_file,
      models: :UploadedFile,
      on: :create,
      criteria: proc do |article, actor|
        article.is_a? UploadedFile
      end,
      publish_if: proc do |uploaded_file, actor|
        # done in add_an_image
        next false if uploaded_file.image?
        uploaded_file.published?
      end,
      object_data_url: proc do |uploaded_file, actor|
        uploaded_file.url.merge view: true
      end,
    },
    add_an_image: {
      # :upload_image verb can't be used as it uses the parent Gallery as target
      # hooked via open_graph_attach_stories
      action_tracker_verb: nil,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :add,
      object_type: :gallery_image,
      models: :UploadedFile,
      on: :create,
      criteria: proc do |article, actor|
        article.is_a? UploadedFile
      end,
      publish_if: proc do |uploaded_file, actor|
        uploaded_file.image? and uploaded_file.parent.is_a? Gallery
      end,
      object_data_url: proc do |uploaded_file, actor|
        uploaded_file.url.merge view: true
      end,
    },
    create_an_article: {
      action_tracker_verb: :create_article,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :create,
      object_type: :blog_post,
      models: :Article,
      on: :create,
      criteria: proc do |article, actor|
        article.parent.is_a? Blog
      end,
      publish_if: proc do |article, actor|
        article.published?
      end,
    },
    create_an_event: {
      action_tracker_verb: :create_article,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :create,
      object_type: :event,
      models: :Event,
      on: :create,
      criteria: proc do |article, actor|
        article.is_a? Event
      end,
      publish_if: proc do |event, actor|
        event.published?
      end,
    },
    start_a_discussion: {
      action_tracker_verb: :create_article,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :start,
      object_type: :forum,
      models: :Article,
      on: :create,
      criteria: proc do |article, actor|
        article.parent.is_a? Forum
      end,
      publish_if: proc do |article, actor|
        article.published?
      end,
    },

    # these a published as passive to give focus to the enterprise
=begin
    add_a_sse_product: {
      action_tracker_verb: :create_product,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :announce_new,
      models: :Product,
      on: :create,
      object_type: :product,
      publish_if: proc do |product, actor|
        product.profile.public?
      end,
    },
    update_a_sse_product: {
      action_tracker_verb: :update_product,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :announce_update,
      object_type: :product,
      models: :Product,
      on: :update,
      publish_if: proc do |product, actor|
        product.profile.public?
      end,
    },
=end

    favorite_a_sse_initiative: {
      action_tracker_verb: :favorite_enterprise,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :favorite,
      object_type: :favorite_enterprise,
      models: :FavoriteEnterprisePerson,
      on: :create,
      object_actor: proc do |favorite_enterprise_person|
        favorite_enterprise_person.person
      end,
      object_profile: proc do |favorite_enterprise_person|
        favorite_enterprise_person.enterprise
      end,
      object_data_url: proc do |favorite_enterprise_person, actor|
        self.og_profile_url favorite_enterprise_person.enterprise
      end,
    },

=begin
    comment_a_discussion: {
      action_tracker_verb: nil,
      action: :comment,
      object_type: :forum,
      models: :Comment,
      on: :create,
      criteria: proc do |comment, actor|
        source, parent = comment.source, comment.source.parent
        source.is_a? Article and parent.is_a? Forum
      end,
      publish_if: proc do |comment, actor|
        comment.source.parent.published?
      end,
    },
    comment_an_article: {
      action_tracker_verb: nil,
      action: :comment,
      object_type: :blog_post,
      models: :Comment,
      on: :create,
      criteria: proc do |comment, actor|
        source, parent = comment.source, comment.source.parent
        source.is_a? Article and parent.is_a? Blog
      end,
      publish_if: proc do |comment, actor|
        comment.source.parent.published?
      end,
    },
=end

    make_friendship_with: {
      action_tracker_verb: :new_friendship,
      track_config: 'OpenGraphPlugin::ActivityTrackConfig',
      action: :make_friendship,
      object_type: :friend,
      models: :Friendship,
      on: :create,
      custom_actor: proc do |friendship|
        friendship.person
      end,
      object_actor: proc do |friendship|
        friendship.person
      end,
      object_profile: proc do |friendship|
        friendship.friend
      end,
      object_data_url: proc do |friendship, actor|
        self.og_profile_url friendship.friend
      end,
    },

    # PASSIVE STORIES
    announce_news_from_a_sse_initiative: {
      action_tracker_verb: :create_article,
      track_config: 'OpenGraphPlugin::EnterpriseTrackConfig',
      action: :announce_news,
      object_type: :enterprise,
      passive: true,
      models: :Article,
      on: :create,
      criteria: proc do |article, actor|
        article.profile.enterprise?
      end,
      publish_if: proc do |article, actor|
        article.published?
      end,
    },
    announce_a_new_sse_product: {
      action_tracker_verb: :create_product,
      track_config: 'OpenGraphPlugin::EnterpriseTrackConfig',
      action: :announce_new,
      object_type: :product,
      passive: true,
      models: :Product,
      on: :create,
      criteria: proc do |product, actor|
        product.profile.enterprise?
      end,
    },
    announce_an_update_of_sse_product: {
      action_tracker_verb: :update_product,
      track_config: 'OpenGraphPlugin::EnterpriseTrackConfig',
      action: :announce_update,
      object_type: :product,
      passive: true,
      models: :Product,
      on: :update,
      criteria: proc do |product, actor|
        product.profile.enterprise?
      end,
    },

    announce_news_from_a_community: {
      action_tracker_verb: :create_article,
      track_config: 'OpenGraphPlugin::CommunityTrackConfig',
      action: :announce_news,
      object_type: :community,
      passive: true,
      models: :Article,
      on: :create,
      criteria: proc do |article, actor|
        article.profile.community?
      end,
      publish_if: proc do |article, actor|
        article.published?
      end,
    },

  }

  ValidObjectList = Definitions.map{ |story, data| data[:object_type] }.uniq
  ValidActionList = Definitions.map{ |story, data| data[:action] }.uniq

  # TODO make this verification work
  #raise "Each active story must use a unique object_type for configuration to work" if ValidObjectList.size < Definitions.size

  DefaultActions = ValidActionList.inject({}){ |h, a| h[a] = a; h }
  DefaultObjects = ValidObjectList.inject({}){ |h, o| h[o] = o; h }

  TrackerStories = {}; Definitions.each do |story, data|
    Array(data[:action_tracker_verb]).each do |verb|
      next unless verb
      TrackerStories[verb] ||= []
      TrackerStories[verb] << story
    end
  end

  TrackConfigStories = {}; Definitions.each do |story, data|
    Array(data[:track_config]).each do |track_config|
      next unless track_config
      TrackConfigStories[track_config] ||= []
      TrackConfigStories[track_config] << [story, data]
    end
  end

  ModelStories = {}; Definitions.each do |story, data|
    Array(data[:models]).each do |model|
      ModelStories[model] ||= {}
      Array(data[:on]).each do |on|
        ModelStories[model][on] ||= []
        ModelStories[model][on] << story
      end
    end
  end

end

