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
    context.url_for(url)
  end

  def birth_date
    object.birth_date.present? ? object.birth_date.strftime('%F') : nil
  end

  def image_base64
    Base64.encode64(image.current_data) if image && image.current_data
  end

  def tags
    articles.published.tag_counts({:order => 'count desc', :limit => 10}).inject({}) do |memo,tag|
      memo[tag.name] = tag.count
      memo
    end
  end

  def communities
    object.communities.public.map {|community| {:url => context.url_for(community.url), :name => community.name}}
  end
end
