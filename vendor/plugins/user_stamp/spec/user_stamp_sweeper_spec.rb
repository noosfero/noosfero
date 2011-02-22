require File.dirname(__FILE__) + '/spec_helper'

class PostsController
  def self.current_user
    @@user
  end
end

describe UserStampSweeper, "#before_validation" do
  before do
    @@user = User.new(220)
    UserStamp.creator_attribute   = :creator
    UserStamp.updater_attribute   = :updater
    UserStamp.current_user_method = :current_user
    @sweeper = UserStampSweeper.instance
    @sweeper.stub!(:controller).and_return(PostsController)
  end
  
  describe "(with new record)" do
    it "should set creator if attribute exists" do
      record = mock('Record', :creator= => nil, :updater= => nil, :new_record? => true, :updater => nil, :creator_id_changed? => false, :creator_type_changed? => false, :updater_id_changed? => false, :updater_type_changed? => false)
      record.should_receive(:creator=).with(@@user).once
      @sweeper.before_validation(record)
    end
    
    it "should NOT set creator if attribute does not exist" do
      record = mock('Record', :new_record? => true, :updater= => nil, :respond_to? => false)
      record.should_receive(:respond_to?).with("creator=").and_return(false)
      record.should_not_receive(:creator=)
      @sweeper.before_validation(record)
    end
  end
  
  describe "(with non new record)" do
    it "should NOT set creator if attribute exists" do
      record = mock('Record', :creator= => nil, :updater= => nil, :updater => nil, :new_record? => false, :creator_id_changed? => false, :creator_type_changed? => false, :updater_id_changed? => false, :updater_type_changed? => false)
      record.should_not_receive(:creator=)
      @sweeper.before_validation(record)
    end
    
    it "should NOT set creator if attribute does not exist" do
      record = mock('Record', :updater= => nil, :updater => nil, :new_record? => false, :creator_id_changed? => false, :creator_type_changed? => false, :updater_id_changed? => false, :updater_type_changed? => false)
      record.should_not_receive(:creator=)
      @sweeper.before_validation(record)
    end
  end
  
  it "should set updater if attribute exists" do
    record = mock('Record', :creator= => nil, :updater= => nil, :new_record? => false, :updater => nil)
    record.should_receive(:updater=)
    @sweeper.before_validation(record)
  end
  
  it "should NOT set updater if attribute does not exist" do
    record = mock('Record', :creator= => nil, :updater= => nil, :new_record? => :false, :respond_to? => false)
    record.should_receive(:respond_to?).with("updater=").and_return(false)
    record.should_not_receive(:updater=)
    @sweeper.before_validation(record)
  end
end

describe UserStampSweeper, "#before_validation (with custom attribute names)" do
  before do
    UserStamp.creator_attribute   = :created_by
    UserStamp.updater_attribute   = :updated_by
    UserStamp.current_user_method = :current_user
    @sweeper = UserStampSweeper.instance
    @sweeper.stub!(:controller).and_return(PostsController)
  end
  
  describe "(with new record)" do
    it "should set created_by if attribute exists" do
      record = mock('Record', :created_by= => nil, :updated_by => nil, :updated_by= => nil, :new_record? => true, :created_by_id_changed? => false, :created_by_type_changed? => false, :updated_by_id_changed? => false, :updated_by_type_changed? => false)
      record.should_receive(:created_by=).with(@@user).once
      @sweeper.before_validation(record)
    end
    
    it "should NOT set created_by if attribute does not exist" do
      record = mock('Record', :new_record? => true, :updated_by= => nil, :respond_to? => false)
      record.should_receive(:respond_to?).with("created_by=").and_return(false)
      record.should_not_receive(:created_by=)
      @sweeper.before_validation(record)
    end
  end
  
  describe "(with non new record)" do
    it "should NOT set created_by if attribute exists" do
      record = mock('Record', :created_by= => nil, :updated_by => nil, :updated_by= => nil, :new_record? => false, :updated_by_id_changed? => false, :updated_by_type_changed? => false)
      record.should_not_receive(:created_by=)
      @sweeper.before_validation(record)
    end
    
    it "should NOT set created_by if attribute does not exist" do
      record = mock('Record', :updated_by= => nil, :updated_by => nil, :new_record? => false, :updated_by_id_changed? => false, :updated_by_type_changed? => false)
      record.should_not_receive(:created_by=)
      @sweeper.before_validation(record)
    end
  end
  
  it "should set updated_by if attribute exists" do
    record = mock('Record', :created_by= => nil, :updated_by= => nil, :updated_by => nil, :new_record? => :false, :created_by_id_changed? => false, :created_by_type_changed? => false, :updated_by_id_changed? => false, :updated_by_type_changed? => false)
    record.should_receive(:updated_by=)
    @sweeper.before_validation(record)
  end
  
  it "should NOT set updated_by if attribute does not exist" do
    record = mock('Record', :created_by= => nil, :updated_by= => nil, :new_record? => :false, :respond_to? => false)
    record.should_receive(:respond_to?).with("updated_by=").and_return(false)
    record.should_not_receive(:updated_by=)
    @sweeper.before_validation(record)
  end

  it "should NOT set created_by if attribute changed" do
    record = mock('Record', :created_by= => nil, :updated_by= => nil, :new_record? => true, :created_by_id_changed? => true, :created_by_type_changed? => true)
    record.should_receive(:respond_to?).with("updated_by=").and_return(false)
    record.should_receive(:respond_to?).with("created_by=").and_return(true)
    record.should_not_receive(:created_by=)
    @sweeper.before_validation(record)
  end

  it "should NOT set updated_by if attribute is not nil" do
    record = mock('Record', :created_by= => nil, :updated_by= => nil, :updated_by => 1, :new_record? => false)
    record.should_receive(:respond_to?).with("updated_by=").and_return(true)
    record.should_receive(:respond_to?).with("created_by=").and_return(false)
    record.should_not_receive(:updated_by=)
    @sweeper.before_validation(record)
  end

  it "should set created_by if attribute has not changed" do
    record = mock('Record', :created_by= => nil, :updated_by= => nil, :new_record? => true, :created_by_id_changed? => false, :created_by_type_changed? => false)
    record.should_receive(:respond_to?).with("updated_by=").and_return(false)
    record.should_receive(:respond_to?).with("created_by=").and_return(true)
    record.should_receive(:created_by=)
    @sweeper.before_validation(record)
  end

  it "should set updated_by if attribute is nil" do
    record = mock('Record', :created_by= => nil, :updated_by= => nil, :updated_by => nil, :new_record? => false)
    record.should_receive(:respond_to?).with("updated_by=").and_return(true)
    record.should_receive(:respond_to?).with("created_by=").and_return(false)
    record.should_receive(:updated_by=)
    @sweeper.before_validation(record)
  end
end

describe UserStampSweeper, "#current_user" do
  before do
    UserStamp.creator_attribute   = :creator
    UserStamp.updater_attribute   = :updater
    UserStamp.current_user_method = :current_user
    @sweeper = UserStampSweeper.instance
  end
  
  it "should send current_user if controller responds to it" do
    user = mock('User')
    controller = mock('Controller', :current_user => user)
    @sweeper.stub!(:controller).and_return(controller)
    controller.should_receive(:current_user)
    @sweeper.send(:current_user)
  end
  
  it "should not send current_user if controller does not respond to it" do
    user = mock('User')
    controller = mock('Controller', :respond_to? => false)
    @sweeper.stub!(:controller).and_return(controller)
    controller.should_not_receive(:current_user)
    @sweeper.send(:current_user)
  end
end

describe UserStampSweeper, "#current_user (with custom current_user_method)" do
  before do
    UserStamp.creator_attribute   = :creator
    UserStamp.updater_attribute   = :updater
    UserStamp.current_user_method = :my_user
    @sweeper = UserStampSweeper.instance
  end
  
  it "should send current_user if controller responds to it" do
    user = mock('User')
    controller = mock('Controller', :my_user => user)
    @sweeper.stub!(:controller).and_return(controller)
    controller.should_receive(:my_user)
    @sweeper.send(:current_user)
  end
  
  it "should not send current_user if controller does not respond to it" do
    user = mock('User')
    controller = mock('Controller', :respond_to? => false)
    @sweeper.stub!(:controller).and_return(controller)
    controller.should_not_receive(:my_user)
    @sweeper.send(:current_user)
  end
end
