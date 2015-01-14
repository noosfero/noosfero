require_dependency 'person'
class Person

  def has_headline?
    !headline.nil?
  end

  def headline
    return nil unless blog
    blog.posts.published.first
  end

end
