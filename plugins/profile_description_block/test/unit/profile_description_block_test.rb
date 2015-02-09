require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")

class ProfileDescriptionBlockTest < ActiveSupport::TestCase
	def setup
		e = Environment.default
    e.enabled_plugins = ['ProfileDescriptionPlugin']
    @person = create_user('test_user').person
    @profile = Profile.create!(:identifier => '1236',
                               :name => 'blabla',
                               :description => "")
	end

  should 'describe itself' do
    assert_not_equal Block.description, ProfileDescriptionBlock.description
  end

  should "show profile description inside block" do
    new_block = ProfileDescriptionBlock.create!
    @profile.boxes.first.blocks << new_block
    block_menssage = "Description field are empty"
    assert (instance_eval(&Block.last.content).include?(block_menssage)),
      "description block doesn't show not found description message"
    description = "This is an test"
    @profile.update_attribute("description", description)
    @profile.save!
    assert (instance_eval(&Block.last.content).include?(description)),
      "Description block doesn't show profile description"
  end
end
