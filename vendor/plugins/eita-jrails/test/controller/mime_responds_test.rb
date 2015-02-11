require 'abstract_unit'
require 'controller/fake_models'
require 'active_support/core_ext/hash/conversions'

class RespondToController < ActionController::Base
  layout :set_layout

  def html_xml_or_rss
    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.xml  { render :text => "XML"     }
      type.rss  { render :text => "RSS"     }
      type.all  { render :text => "Nothing" }
    end
  end

  def js_or_html
    respond_to do |type|
      type.js   { render :text => "JS"      }
    end
  end

  def json_or_yaml
    respond_to do |type|
      type.json { render :text => "JSON" }
      type.yaml { render :text => "YAML" }
    end
  end

  def html_or_xml
    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.xml  { render :text => "XML"     }
      type.all  { render :text => "Nothing" }
    end
  end

  def json_xml_or_html
    respond_to do |type|
      type.json { render :text => 'JSON' }
      type.xml { render :xml => 'XML' }
      type.html { render :text => 'HTML' }
    end
  end


  def forced_xml
    request.format = :xml

    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.xml  { render :text => "XML"     }
    end
  end

  def just_xml
    respond_to do |type|
      type.xml  { render :text => "XML" }
    end
  end

  def using_defaults
    respond_to do |type|
      type.js
    end
  end

  def using_defaults_with_type_list
    respond_to(:js)
  end

  def made_for_content_type
    respond_to do |type|
      type.rss  { render :text => "RSS"  }
      type.atom { render :text => "ATOM" }
      type.all  { render :text => "Nothing" }
    end
  end

  def custom_type_handling
    respond_to do |type|
      type.html { render :text => "HTML"    }
      type.custom("application/crazy-xml")  { render :text => "Crazy XML"  }
      type.all  { render :text => "Nothing" }
    end
  end


  def custom_constant_handling
    respond_to do |type|
      type.html   { render :text => "HTML"   }
      type.mobile { render :text => "Mobile" }
    end
  end

  def custom_constant_handling_without_block
    respond_to do |type|
      type.html   { render :text => "HTML"   }
      type.mobile
    end
  end

  def handle_any
    respond_to do |type|
      type.html { render :text => "HTML" }
      type.any(:js, :xml) { render :text => "Either JS or XML" }
    end
  end

  def handle_any_any
    respond_to do |type|
      type.html { render :text => 'HTML' }
      type.any { render :text => 'Whatever you ask for, I got it' }
    end
  end

  def all_types_with_layout
    respond_to do |type|
      type.js
    end
  end


  def iphone_with_html_response_type
    request.format = :iphone if request.env["HTTP_ACCEPT"] == "text/iphone"

    respond_to do |type|
      type.html   { @type = "Firefox" }
      type.iphone { @type = "iPhone"  }
    end
  end

  def iphone_with_html_response_type_without_layout
    request.format = "iphone" if request.env["HTTP_ACCEPT"] == "text/iphone"

    respond_to do |type|
      type.html   { @type = "Firefox"; render :action => "iphone_with_html_response_type" }
      type.iphone { @type = "iPhone" ; render :action => "iphone_with_html_response_type" }
    end
  end

  def rescue_action(e)
    raise
  end

  protected
    def set_layout
      if ["all_types_with_layout", "iphone_with_html_response_type"].include?(action_name)
        "respond_to/layouts/standard"
      elsif action_name == "iphone_with_html_response_type_without_layout"
        "respond_to/layouts/missing"
      end
    end
end


class RespondToControllerTest < ActionController::TestCase
  tests RespondToController

  def test_using_defaults
    @request.accept = "text/javascript"
    get :using_defaults
    assert_equal "text/javascript", @response.content_type
    assert_equal '$("body").visualEffect("highlight");', @response.body
  end

  def test_using_defaults_with_type_list
    @request.accept = "text/javascript"
    get :using_defaults_with_type_list
    assert_equal "text/javascript", @response.content_type
    assert_equal '$("body").visualEffect("highlight");', @response.body
  end

  def test_rjs_type_skips_layout
    @request.accept = "text/javascript"
    get :all_types_with_layout
    assert_equal 'RJS for all_types_with_layout', @response.body
  end

  def test_xhr
    xhr :get, :using_defaults
    assert_equal '$("body").visualEffect("highlight");', @response.body
  end
end

class RespondWithController < ActionController::Base
  respond_to :html, :json, :js

  def using_resource
    respond_with(resource)
  end
protected

  def resource
    Customer.new("david", request.delete? ? nil : 13)
  end

  def _render_js(js, options)
    self.content_type ||= Mime::JS
    self.response_body = js.respond_to?(:to_js) ? js.to_js : js
  end
end

class RespondWithControllerTest < ActionController::TestCase
  tests RespondWithController

  def test_using_resource
    @request.accept = "text/javascript"
    get :using_resource
    assert_equal "text/javascript", @response.content_type
    assert_equal '$("body").visualEffect("highlight");', @response.body
  end
end
