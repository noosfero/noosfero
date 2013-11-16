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
          :description => 'Cool form'},
        :fields => {
          1 => {
            :name => 'Name',
            :default_value => 'Jack',
            :type => 'text_field'
          },
          2 => {
            :name => 'Color',
            :list => '1',
            :type => 'select_field',
            :choices => {
              1 => {:name => 'Red', :value => 'red'},
              2 => {:name => 'Blue', :value => 'blue'},
              3 => {:name => 'Black', :value => 'black'}
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

    f1 = form.fields.first
    f2 = form.fields.last

    assert_equal 'Name', f1.name
    assert_equal 'Jack', f1.default_value
    assert f1.kind_of?(CustomFormsPlugin::TextField)

    assert_equal 'Color', f2.name
    assert_equal 'red', f2.choices['Red']
    assert_equal 'blue', f2.choices['Blue']
    assert_equal 'black', f2.choices['Black']
    assert f2.list
    assert f2.kind_of?(CustomFormsPlugin::SelectField)
  end

  should 'create fields in the order they are sent' do
    format = '%Y-%m-%d %H:%M'
    num_fields = 10
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)
    fields = {}
    num_fields.times do |i|
      fields[i.to_s] = {
        :name => i.to_s,
        :default_value => '',
        :type => 'text_field'
      }
    end
    assert_difference CustomFormsPlugin::Form, :count, 1 do
      post :create, :profile => profile.identifier,
        :form => {
        :name => 'My Form',
        :access => 'logged',
        :begining => begining,
        :ending => ending,
        :description => 'Cool form'},
        :fields => fields
    end
    form = CustomFormsPlugin::Form.find_by_name('My Form')
    assert_equal num_fields, form.fields.count
    form.fields.find_each do |f|
      assert_equal f.position, f.name.to_i
    end
  end

  should 'edit a form' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')
    field = CustomFormsPlugin::TextField.create!(:form => form, :name => 'License')
    format = '%Y-%m-%d %H:%M'
    begining = Time.now.strftime(format)
    ending = (Time.now + 1.day).strftime(format)

    post :edit, :profile => profile.identifier, :id => form.id,
      :form => {:name => 'My Form', :access => 'logged', :begining => begining, :ending => ending, :description => 'Cool form'},
      :fields => {1 => {:real_id => field.id.to_s, :name => 'Source'}}

    form.reload
    field.reload

    assert_equal 'logged', form.access
    assert_equal begining, form.begining.strftime(format)
    assert_equal ending, form.ending.strftime(format)
    assert_equal 'Cool form', form.description
    assert_equal 'Source', field.name
  end

  should 'render TinyMce Editor for description' do
    form = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Free Software')

    get :edit, :profile => profile.identifier, :id => form.id

    assert_tag :tag => 'textarea', :attributes => { :id => 'form_description', :class => 'mceEditor' }
  end

end

