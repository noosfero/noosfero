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
    #     user_profile_path(User.find_by(login: $1))

    when /^\//
      page_name

    when /the welcome page/
      '/site/welcome'

    when /article "([^"]+)"\s*$/
      url_for(Article.find_by(name: $1).url.merge({:only_path => true}))

    when /category "([^"]+)"/
      '/cat/%s' % Category.find_by(name: $1).slug

    when /edit "(.+)" by (.+)/
      article_id = Person[$2].articles.find_by(slug: $1.to_slug).id
      "/myprofile/#{$2}/cms/edit/#{article_id}"

    when /edit (.*Block) of (.+)/
      owner = Profile[$2]
      klass = $1.constantize
      block = klass.all.select{|i| i.owner == owner}.first
      "/myprofile/#{$2}/profile_design/edit/#{block.id}"

    when /^(.*)'s homepage$/
      '/' + profile_identifier($1)

    when /^(.*)'s blog$/
      '/%s/blog' % profile_identifier($1)

    when /^(.*)'s (.+) creation$/
      '/myprofile/%s/cms/new?type=%s' % [profile_identifier($1),$2]

    when /^(.*)'s sitemap/
      '/profile/%s/sitemap' % profile_identifier($1)

    when /^(.*)'s profile$/
      '/profile/' + profile_identifier($1)

    when /^(.*)'s join page/
      '/profile/%s/join' % profile_identifier($1)

    when /^(.*)'s leave page/
      '/profile/%s/leave' % profile_identifier($1)

    when /^login page$/
      '/account/login'

    when /^logout page$/
      '/account/logout'

    when /^signup page$/
      '/account/signup'

    when /^(.*)'s control panel$/
      '/myprofile/' + profile_identifier($1)

    when /the environment control panel/
      '/admin'

    when /^the search page$/
      '/search'

    when /^the search (.+) page$/
      '/search/%s' % $1

    when /^(.+)'s cms/
      '/myprofile/%s/cms' % profile_identifier($1)

    when /^"(.+)" edit page/
      article = Article.find_by name: $1
      '/myprofile/%s/cms/edit/%s' % [article.profile.identifier, article.id]

    when /^(.+)'s members management/
      '/myprofile/%s/profile_members' % Profile.find_by(name: $1).identifier

    when /^(.+)'s new product page/
      '/myprofile/%s/manage_products/new' % profile_identifier($1)

    when /^(.+)'s page of product (.*)$/
      enterprise = Profile.find_by(name: $1)
      product = enterprise.products.find_by(name: $2)
      '/myprofile/%s/manage_products/show/%s' % [enterprise.identifier, product.id]

    when /^(.*)'s products page$/
      '/catalog/%s' % $1

    when /^chat$/
      '/chat'

    when /^(.+)'s tag page/
      '/tag/%s' % $1

    when /the user data path/
      '/account/user_data'

    when /^(.+)'s confirmation URL/
      user = User[$1]
      "/account/activate?activation_code=#{user.activation_code}&redirection=" + (user.return_to.nil? ? 'false' : 'true')

    when /^(.+)'s members page/
      '/profile/%s/members' % profile_identifier($1)

    when /^(.+)'s "(.+)" page from "(.*)" of "(.*)" plugin/
      profile = $1
      action = $2
      plugin_name = $4.underscore
      controller_type = $3.constantize.superclass.to_s.underscore.gsub(/_controller/, "")
      "/#{controller_type}/#{profile}/plugin/#{plugin_name}/#{action}"

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

  def profile_identifier(field)
    profile = Profile.find_by(name: field) || Profile.find_by(identifier: field)
    profile.identifier
  end
end

World(NavigationHelpers)
