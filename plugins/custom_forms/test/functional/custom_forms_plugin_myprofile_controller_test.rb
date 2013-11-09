require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/custom_forms_plugin_myprofile_controller'

# Re-raise errors caught by the controller.
class CustomFormsPluginMyprofileController; def rescue_action(e) raise e end; end

class CustomFormsPluginMyprofileControllerTest < ActionController::TestCase
  def setup
    @controller = CustomFormsPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('profile').person
    login_as(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(CustomFormsPlugin)
  end

  attr_reader :profile

  should 'list forms associated with profile' do
    another_profile = fast_create(Profile)
    f1 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    f2 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Open Source')
    f3 = CustomFormsPlugin::Form.create!(:profile => another_profile, :name => 'Open Source')

    get :index, :profile => profile.identifier

    assert_includes assigns(:forms), f1
    assert_includes assigns(:forms), f2
    assert_not_includes assigns(:forms), f3
  end

  should 'destroy form' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    assert CustomFormsPlugin::Form.exists?(form.id)
    post :remove, :profile => profile.identifier, :id => form.id
    assert !CustomFormsPlugin::Form.exists?(form.id)
  end

  should 'create a form' do
    format = '%Y-%m-%d %H:%M'
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)
    assert_difference CustomFormsPlugin::Form, :count, 1 do
      post :create, :profile => profile.identifier,
        :form => {
          :name => 'My Form',
          :access => 'logged',
          :begining => begining,
          :ending => ending,
          :description => 'Cool form',
          :fields_attributes => {
            1 => {
              :name => 'Name',
              :default_value => 'Jack',
              :type => 'CustomFormsPlugin::TextField'
            },
            2 => {
              :name => 'Color',
              :select_field_type => 'radio',
              :type => 'CustomFormsPlugin::SelectField',
              :alternatives_attributes => {
                1 => {:label => 'Red'},
                2 => {:label => 'Blue'},
                3 => {:label => 'Black'}
              }
            }
          }
        }
    end

    form = CustomFormsPlugin::Form.find_by_name('My Form')
    assert_equal 'logged', form.access
    assert_equal begining, form.begining.strftime(format)
    assert_equal ending, form.ending.strftime(format)
    assert_equal 'Cool form', form.description
    assert_equal 2, form.fields.count

    f1 = form.fields[0]
    f2 = form.fields[1]

    assert_equal 'Name', f1.name
    assert_equal 'Jack', f1.default_value
    assert f1.kind_of?(CustomFormsPlugin::TextField)

    assert_equal 'Color', f2.name
    assert_equal f2.alternatives.map(&:label).sort, ['Red', 'Blue', 'Black'].sort
    assert_equal f2.select_field_type, 'radio'
    assert f2.kind_of?(CustomFormsPlugin::SelectField)
  end

  should 'create fields in the order they are sent when no position defined' do
    format = '%Y-%m-%d %H:%M'
    num_fields = 10
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)
    fields = {}
    num_fields.times do |i|
      fields[i] = {
        :name => (10-i).to_s,
        :default_value => '',
        :type => 'CustomFormsPlugin::TextField'
      }
    end
    assert_difference CustomFormsPlugin::Form, :count, 1 do
      post :create, :profile => profile.identifier,
        :form => {
        :name => 'My Form',
        :access => 'logged',
        :begining => begining,
        :ending => ending,
        :description => 'Cool form',
        :fields_attributes => fields
      }
    end
    form = CustomFormsPlugin::Form.find_by_name('My Form')
    assert_equal num_fields, form.fields.count
    lst = 10
    form.fields.each do |f|
      assert f.name.to_i == lst
      lst = lst - 1
    end
  end

  should 'create fields in any position size' do
    format = '%Y-%m-%d %H:%M'
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)
    fields = {}
    fields['0'] = {
      :name => '0',
      :default_value => '',
      :type => 'CustomFormsPlugin::TextField',
      :position => '999999999999'
    }
    fields['1'] = {
      :name => '1',
      :default_value => '',
      :type => 'CustomFormsPlugin::TextField',
      :position => '1'
    }
    assert_difference CustomFormsPlugin::Form, :count, 1 do
      post :create, :profile => profile.identifier,
        :form => {
        :name => 'My Form',
        :access => 'logged',
        :begining => begining,
        :ending => ending,
        :description => 'Cool form',
        :fields_attributes => fields
      }
    end
    form = CustomFormsPlugin::Form.find_by_name('My Form')
    assert_equal 2, form.fields.count
    assert form.fields.first.name == "1"
    assert form.fields.last.name == "0"
  end

  should 'edit a form' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    format = '%Y-%m-%d %H:%M'
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)

    assert_equal form.fields.length, 0

    post :update, :profile => profile.identifier, :id => form.id,
      :form => {:name => 'My Form', :access => 'logged', :begining => begining, :ending => ending, :description => 'Cool form',
        :fields_attributes => {1 => {:name => 'Source'}}}

    form.reload
    assert_equal form.fields.length, 1

    field = form.fields.last

    assert_equal 'logged', form.access
    assert_equal begining, form.begining.strftime(format)
    assert_equal ending, form.ending.strftime(format)
    assert_equal 'Cool form', form.description
    assert_equal 'Source', field.name
  end
end

