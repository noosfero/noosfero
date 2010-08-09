require "#{File.dirname(__FILE__)}/../test_helper"
require 'benchmark'

class PerformanceTest < ActionController::IntegrationTest

  all_fixtures

  # Testing blog page display. It should not present a linear increase in time
  # needed to display a blog page with the increase in number of posts.
  #
  # GOOD          BAD
  #  
  # ^             ^     /
  # |             |    /
  # |   _____     |   /
  # |  /          |  /
  # | /           | /
  # |/            |/
  # +--------->   +--------->
  # 0  50  100    0  50  100
  #
  should 'not have a linear increase in time to display a blog page' do
    person = create_profile('clueless')

    # no posts
    time0 = (Benchmark.measure { get '/clueless/blog' })

    # first 50
    create_posts(person)
    time1 = (Benchmark.measure { get '/clueless/blog' })

    # another 50
    create_posts(person)
    time2 = (Benchmark.measure { get '/clueless/blog' })

    # should not scale linearly, i.e. the inclination of the first segment must
    # be a lot higher than the one of the segment segment. To compensate for
    # small variations due to hardware and/or execution environment, we are
    # satisfied if the the inclination of the first segment is at least twice
    # the inclination of the second segment.
    a1 = (time1.total - time0.total)/50.0
    a2 = (time2.total - time1.total)/50.0
    assert a1 > a2*2, "#{a1} should be larger than #{a2} by at least a factor of 2"
  end

  protected

  def create_profile(name)
    person = create_user(name).person
    Blog.create(:name => "Blog", :profile => person)
    person
  end

  def create_posts(profile)
    postnumber = profile.articles.count
    blog = profile.blog
    50.times do |i|
      postnumber += 1
      TinyMceArticle.create!(:profile => profile, :parent => blog, :name => "post number #{postnumber}")
    end
  end

end

