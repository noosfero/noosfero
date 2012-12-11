module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    when /^\//
      page_name

    when /article "([^"]+)"\s*$/
      url_for(Article.find_by_name($1).url.merge({:only_path => true}))

    when /category "([^"]+)"/
      '/cat/%s' % Category.find_by_name($1).slug

    when /edit "(.+)" by (.+)/
      article_id = Person[$2].articles.find_by_slug($1.to_slug).id
      "/myprofile/#{$2}/cms/edit/#{article_id}"

    when /edit (.*Block) of (.+)/
      owner = Profile[$2]
      klass = $1.constantize
      block = klass.find(:all).select{|i| i.owner == owner}.first
      "/myprofile/#{$2}/profile_design/edit/#{block.id}"

    when /^(.*)'s homepage$/
      '/' + $1

    when /^(.*)'s blog$/
      '/%s/blog' % Profile.find_by_name($1).identifier

    when /^(.*)'s (.+) creation$/
      '/myprofile/%s/cms/new?type=%s' % [Profile.find_by_name($1).identifier,$2]

    when /^(.*)'s sitemap/
      '/profile/%s/sitemap' % Profile.find_by_name($1).identifier

    when /^(.*)'s profile$/
      '/profile/' + $1

    when /^(.*)'s join page/
      '/profile/%s/join' % Profile.find_by_name($1).identifier

    when /^(.*)'s leave page/
      '/profile/%s/leave' % Profile.find_by_name($1).identifier

    when /^(.*)'s profile editor$/
      "myprofile/manuel/profile_editor/edit"

    when /^login page$/
      '/account/login'

    when /^logout page$/
      '/account/logout'

    when /^signup page$/
      '/account/signup'

    when /^(.*)'s control panel$/
      '/myprofile/' + $1

    when /the environment control panel/
      '/admin'

    when /^the search page$/
      '/search'

    when /^the search (.+) page$/
      '/search/%s' % $1

    when /^(.+)'s cms/
      '/myprofile/%s/cms' % Profile.find_by_name($1).identifier

    when /^"(.+)" edit page/
      article = Article.find_by_name($1)
      '/myprofile/%s/cms/edit/%s' % [article.profile.identifier, article.id]

    when /^(.+)'s members management/
      '/myprofile/%s/profile_members' % Profile.find_by_name($1).identifier

    when /^(.+)'s new product page/
      '/myprofile/%s/manage_products/new' % Profile.find_by_name($1).identifier

    when /^(.+)'s page of product (.*)$/
      enterprise = Profile.find_by_name($1)
      product = enterprise.products.find_by_name($2)
      '/myprofile/%s/manage_products/show/%s' % [enterprise.identifier, product.id]

    when /^(.*)'s products page$/
      '/catalog/%s' % Profile.find_by_name($1).identifier

    when /^chat$/
      '/chat'

    when /^(.+)'s tag page/
      '/tag/%s' % $1

    when /the user data path/
      '/account/user_data'

    when /^(.+)'s members page/
      '/profile/%s/members' % Profile.find_by_name($1).identifier

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
