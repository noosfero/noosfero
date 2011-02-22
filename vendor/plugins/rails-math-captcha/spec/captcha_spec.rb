require 'lib/math_captcha/captcha'
require 'base64'

describe Captcha do
  describe "with a random task" do
    before(:each) do
      @captcha = Captcha.new
    end
    it "should have arguments and an operator" do
      @captcha.x.should_not be_nil
      @captcha.y.should_not be_nil
      @captcha.operator.should_not be_nil
    end
    it "should use numbers bigger than zero" do
      @captcha.x.should > 0
      @captcha.y.should > 0
    end
    it "should offer a human readable task" do
      @captcha.task.should =~ /^\d+\s*[\+\-\*]\s*\d+$/
    end
    it "should have a secret to use in forms" do
      @captcha.to_secret.should_not be_nil
      @captcha.to_secret.should_not be_empty
    end

    it "should re-use its cipher" do
      @captcha.send(:cipher).should == @captcha.send(:cipher)
    end

    it "should have a base64 encoded secret" do
      lambda { Base64.decode64(@captcha.to_secret).should_not be_nil }.should_not raise_error
    end

    describe "re-creating another from secret" do
      before(:each) do
        @secret = @captcha.to_secret
        @new_captcha = Captcha.from_secret(@secret)
      end
      it "should have the same arguments and operator" do
        @new_captcha.x.should == @captcha.x
        @new_captcha.y.should == @captcha.y
        @new_captcha.operator.should == @captcha.operator
      end
      it "should have the same string" do
        @new_captcha.task.should == @captcha.task
      end
    end
  end
end
