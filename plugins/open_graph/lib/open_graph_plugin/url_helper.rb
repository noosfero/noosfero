module OpenGraphPlugin::UrlHelper

  protected

  include MetadataPlugin::UrlHelper

  # Call don't ask: move to a og_url method inside object
  def url_for object, custom_url=nil, extra_params={}
    return custom_url if custom_url.is_a? String
    url = custom_url || if object.is_a? Profile then og_profile_url object else object.url end
    # for profile when custom domain is used
    url.merge! profile: object.profile.identifier if object.respond_to? :profile
    url.merge! extra_params
    self.og_url_for url
  end

  def passive_url_for object, custom_url, story_defs, extra_params={}
    object_type = story_defs[:object_type]
    og_type = MetadataPlugin.og_types[object_type]
    extra_params.merge! og_type: og_type if og_type.present?
    self.url_for object, custom_url, extra_params
  end

end
