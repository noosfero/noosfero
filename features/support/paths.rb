module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      '/'

    when /^\//
      page_name

    when /edit "(.+)" by (.+)/
      article_id = Person[$2].articles.find_by_slug($1.to_slug).id
      "/myprofile/#{$2}/cms/edit/#{article_id}"
    
    when /edit BlogArchivesBlock of (.+)/
      owner = Profile[$1]
      block = BlogArchivesBlock.find(:all).select{|i| i.owner == owner}.first
      "/myprofile/#{$1}/profile_design/edit/#{block.id}"

    when /^(.*)'s homepage$/
      '/%s' % Profile.find_by_name($1).identifier

    when /^(.*)'s sitemap/
      '/profile/%s/sitemap' % Profile.find_by_name($1).identifier

    when /^login page$/
      '/account/login'

    when /^signup page$/
      '/account/signup'

    when /^(.*)'s control panel$/
      '/myprofile/%s' % Profile.find_by_name($1).identifier

    when /^the search page$/
      '/search'

    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
