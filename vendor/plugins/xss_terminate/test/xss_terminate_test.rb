require File.join(File.dirname(__FILE__), 'setup_test')

class XssTerminateTest < Test::Unit::TestCase

  XssTerminate.sanitize_by_default = true

  def test_sanitize_by_default_is_true
    assert XssTerminate.sanitize_by_default
  end

  
  def test_strip_tags_on_discovered_fields
    c = Comment.create!(:title => "<script>alert('xss in title')</script>",
                        :body => "<script>alert('xss in body')</script>")

    assert_equal "alert('xss in title')", c.title
    
    assert_equal "alert('xss in body')", c.body
  end
  
  def test_rails_sanitization_on_specified_fields
    e = Entry.create!(:title => "<script>alert('xss in title')</script>",
                      :body => "<script>alert('xss in body')</script>",
                      :extended => "<script>alert('xss in extended')</script>",
                      :person_id => 1)

    assert_equal [:body, :extended], e.xss_terminate_options[:only]
    
    assert_equal "alert('xss in title')", e.title

    assert_equal "", e.body

    assert_equal "", e.extended
  end
  
  def test_excepting_specified_fields
    p = Person.create!(:name => "<strong>Mallory</strong>")
    
    assert_equal [:name], p.xss_terminate_options[:except]
    
    assert_equal "<strong>Mallory</strong>", p.name
  end
  
  
  def test_html5lib_sanitization_on_specified_fields
    r = Review.create!(:title => "<script>alert('xss in title')</script>",
                       :body => "<script>alert('xss in body')</script>",
                       :extended => "<script>alert('xss in extended')</script>",
                       :person_id => 1)
                       
    assert_equal [:body, :extended], r.xss_terminate_options[:html5lib_sanitize]

    assert_equal "alert('xss in title')", r.title
    
    assert_equal "&lt;script&gt;alert('xss in body')&lt;/script&gt;", r.body
    
    assert_equal "&lt;script&gt;alert('xss in extended')&lt;/script&gt;", r.extended
  end


  ### Tests for new features (the API rewriten)

  def test_onlying_specified_fields
    p = Message.create!(:body => "<strong>Mallory</strong>")
    
    assert_equal [:body], p.xss_terminate_options[:only]
    
    assert_equal "Mallory", p.body
  end

end
