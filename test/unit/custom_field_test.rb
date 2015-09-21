require_relative "../test_helper"

class CustomFieldTest < ActiveSupport::TestCase

  def setup
    @person = create_user('test_user').person

    @e1 = Environment.default
    @e2 = fast_create(Environment)

    @community = create(Community, :environment => @e1, :name => 'my new community')

    @community_custom_field = CustomField.create(:name => "community_field", :format=>"myFormat", :default_value => "value for community", :customized_type=>"Community", :active => true, :environment => @e1)
    @person_custom_field = CustomField.create(:name => "person_field", :format=>"myFormat", :default_value => "value for person", :customized_type=>"Person", :active => true, :environment => @e1)
    @profile_custom_field = CustomField.create(:name => "profile_field", :format=>"myFormat", :default_value => "value for any profile", :customized_type=>"Profile", :active => true, :environment => @e1)

    @e1.reload
  end

  should 'not access another environments custom fields' do
    @e2_custom_field = CustomField.create(:name => "another_field", :format=>"anoherFormat", :default_value => "default value for e2", :customized_type=>"Profile", :active => true, :environment => @e2)
    @e2.reload

    assert_equal 1, Profile.custom_fields(@e1).size
    assert_equal @profile_custom_field, Profile.custom_fields(@e1).first

    assert_equal 1, Profile.custom_fields(@e2).size
    assert_equal @e2_custom_field, Profile.custom_fields(@e2).first

  end

  should 'no access to custom field on sibling' do
    refute (Person.custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name})
    refute (Community.custom_fields(@e1).any?{|cf| cf.name == @person_custom_field.name})
  end

  should 'inheritance of custom_field' do
    assert Community.custom_fields(@e1).any?{|cf| cf.name == @profile_custom_field.name}
    assert Person.custom_fields(@e1).any?{|cf| cf.name == @profile_custom_field.name}
  end

  should 'save custom_field_values' do
    @community.custom_values = {"community_field" => "new_value!", "profile_field"=> "another_value!"}
    @community.save

    assert CustomFieldValue.all.any?{|cv| cv.custom_field_id == @community_custom_field.id && cv.customized_id == @community.id && cv.value == "new_value!"}
    assert CustomFieldValue.all.any?{|cv| cv.custom_field_id == @profile_custom_field.id && cv.customized_id == @community.id && cv.value = "another_value!"}
  end

  should 'delete custom field and its values' do
    @community.custom_values = {"community_field" => "new_value!", "profile_field"=> "another_value!"}
    @community.save

    old_id = @community_custom_field.id
    @community_custom_field.destroy

    @e1.reload
    refute (@e1.custom_fields.any?{|cf| cf.id == old_id})
    refute (Community.custom_fields(@e1).any?{|cf| cf.name == "community_field"})
    refute (CustomFieldValue.all.any?{|cv| cv.custom_field_id == old_id})
  end

  should 'not save related custom field' do
    another_field = CustomField.create(:name => "profile_field", :format=>"myFormat", :default_value => "value for any profile", :customized_type=>"Community", :environment => @e1)
    assert another_field.id.nil?
  end

  should 'not save same custom field twice in the same environment' do
    field = CustomField.create(:name => "the new field", :format=>"myFormat", :customized_type=>"Community", :environment => @e1)
    refute field.id.nil?
    @e1.reload
    another = CustomField.new(:name => "the new field", :format=>"myFormat", :customized_type=>"Community", :environment => @e1)
    refute another.valid?
  end

  should 'save same custom field in another environment' do
    field = CustomField.create(:name => "the new field", :format=>"myFormat", :customized_type=>"Community", :environment => @e1)
    refute field.id.nil?
    another_field = CustomField.create(:name => "the new field", :format=>"myFormat", :customized_type=>"Community", :environment => @e2)
    refute another_field.id.nil?
  end

  should 'not return inactive fields' do
    @community_custom_field.update_attributes(:active=>false)
    @e1.reload
    refute Community.active_custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name}
  end

  should 'delete a model and its custom field values' do
    @community.custom_values = {"community_field" => "new_value!", "profile_field"=> "another_value!"}
    @community.save

    old_id = @community.id
    @community.destroy
    refute (Community.all.any?{|c| c.id == old_id})
    refute (CustomFieldValue.all.any?{|cv| cv.customized_id == old_id && cv.customized_type == "Community"})
  end

  should 'keep field value if the field is reactivated' do

    @community.custom_values = {"community_field" => "new_value!"}
    @community.save

    @community_custom_field.update_attributes(:active=>false)
    @e1.reload
    refute Community.active_custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name}

    @community_custom_field.update_attributes(:active=>true)

    @e1.reload
    @community.reload
    assert Community.active_custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name}
    assert_equal @community.custom_value("community_field"), "new_value!"
  end

  should 'list of required fields' do
    refute Community.required_custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name}

    @community_custom_field.update_attributes(:required=>true)
    @community.reload
    @e1.reload
    assert Community.required_custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name}
  end

  should 'list of signup fields' do
    refute Community.signup_custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name}

    @community_custom_field.update_attributes(:signup=>true)
    @community.reload
    @e1.reload
    assert Community.signup_custom_fields(@e1).any?{|cf| cf.name == @community_custom_field.name}
  end

  should 'public values handling' do
    refute @community.is_public("community_field")
    @community.custom_values = {"community_field" => {"value" => "new_value!", "public"=>"true"}, "profile_field"=> "another_value!"}
    @community.save
    @community.reload

    assert @community.is_public("community_field")
    refute @community.is_public("profile_field")
  end

  should 'complete list of fields' do
    assert Person.custom_fields(@e1).include? @profile_custom_field
    assert Person.custom_fields(@e1).include? @person_custom_field
  end

  should 'get correct customized ancestors list' do
    assert (Person.customized_ancestors_list-["Person","Profile"]).blank?
  end
end

