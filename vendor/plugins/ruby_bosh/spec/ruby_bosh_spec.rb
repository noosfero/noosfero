require File.join(File.dirname(__FILE__), 'spec_helper')

describe RubyBOSH do
  before(:each) do 
    RubyBOSH.logging = false
    @rbosh = RubyBOSH.new("skyfallsin@localhost", "skyfallsin",
                          "http://localhost:5280/http-bind")
    #@rbosh.stub!(:success?).and_return(true)
    #@rbosh.stub!(:initialize_bosh_session).and_return(true)
    @rbosh.stub!(:send_auth_request).and_return(true)
    @rbosh.stub!(:send_restart_request).and_return(true)
    @rbosh.stub!(:request_resource_binding).and_return(true)
    @rbosh.stub!(:send_session_request).and_return(true)
    RestClient.stub!(:post).and_return("<body sid='123456'></body>")
  end

  it "should set the sid attribute after the session creation request" do
    @rbosh.connect
    @rbosh.sid.should == '123456'
  end

  it "should update the rid on every call to the BOSH server" do
    @rbosh.rid = 100
    @rbosh.connect
    @rbosh.rid.should > 100
  end

  it "should return an array with [jid, sid, rid] on success" do
    s = @rbosh.connect
    s.should be_kind_of(Array)
    s.size.should == 3
    s.first.should == 'skyfallsin@localhost' 
    s.last.should be_kind_of(Fixnum)
    s[1].should == '123456'
  end

  describe "Errors" do
    it "should crash with AuthFailed when its not a success?" do
      @rbosh.stub!(:send_session_request).and_return(false)
      lambda { @rbosh.connect }.should raise_error(RubyBOSH::AuthFailed)
    end

    it "should raise a ConnFailed if a connection could not be made to the XMPP server" do
      RestClient.stub!(:post).and_raise(Errno::ECONNREFUSED)
      lambda { @rbosh.connect }.should raise_error(RubyBOSH::ConnFailed)
    end

    it "should raise a Timeout::Error if the BOSH call takes forever" do
      SystemTimer.stub!(:timeout).and_raise(::Timeout::Error)
      lambda { @rbosh.connect }.should raise_error(RubyBOSH::Timeout)
    end

    it "should crash with a generic error on any other problem" do
      [RestClient::ServerBrokeConnection, RestClient::RequestTimeout].each{|err|
        RestClient.stub!(:post).and_raise(err)
        lambda { @rbosh.connect }.should raise_error(RubyBOSH::Error)
      }
    end

    after(:each) do
      lambda { @rbosh.connect }.should raise_error(RubyBOSH::Error)
    end
  end
end
