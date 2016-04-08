class StoaPlugin::PersonApi < Noosfero::FieldsDecorator
  def username
    user.login
  end

  def nusp
    usp_id
  end

  def first_name
    name.split(' ').first
  end

  def surname
    name.split(' ',2).last
  end

  def homepage
    profile_homepage(context, object)
  end

  def birth_date
    object.birth_date.present? ? object.birth_date.strftime('%F') : nil
  end

  def image_base64
    Base64.encode64(image.current_data) if image && image.current_data
  end

  def tags
    articles.published.tag_counts.order('count desc').limit(10).inject({}) do |memo,tag|
      memo[tag.name] = tag.count
      memo
    end
  end

  def communities
    object.communities.is_public.map {|community| {:url => profile_homepage(context, community), :name => community.name}}
  end

  private

  def profile_homepage(context, profile)
    if context.respond_to?(:url_for)
      context.url_for(profile.url)
    else
      profile.environment.top_url + '/' + profile.identifier
    end
  end
end
