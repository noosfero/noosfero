class SuggestArticle < Task

  has_captcha  

  serialize :data, Hash
  acts_as_having_settings :field => :data

  validates_presence_of :target_id, :article_name, :email, :name, :article_body

  def description
    _('%{sender} suggested to publish "%{article}" on %{community}') % { :sender => sender, :article => article_name, :community => target.name }
  end

  settings_items :email, :type => String
  settings_items :name, :type => String
  settings_items :article_name, :type => String
  settings_items :article_body, :type => String
  settings_items :article_abstract, :type => String
  settings_items :article_parent_id, :type => String
  settings_items :source, :type => String
  settings_items :source_name, :type => String
  settings_items :highlighted, :type => :boolean

  def sender
    "#{name} (#{email})"
  end

  def perform
    TinyMceArticle.create!(
      :profile => target,
      :name => article_name,
      :body => article_body,
      :abstract => article_abstract,
      :parent_id => article_parent_id,
      :source => source,
      :source_name => source_name,
      :highlighted => highlighted
    )
  end

end
