require_relative "../test_helper"

class ForgotPasswordHelperTest < ActionView::TestCase
  include ForgotPasswordHelper

  def setup
    @environment = Environment.default
    @plugins = Noosfero::Plugin::Manager.new(@environment, self)
  end

  attr_accessor :environment

  should 'allow extra fields provided by plugins' do
    class Plugin1 < Noosfero::Plugin
      def change_password_fields
        {:field => 'f1', :name => 'F1', :model => 'person'}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def change_password_fields
        [{:field => 'f2', :name => 'F2', :model => 'person'},
         {:field => 'f3', :name => 'F3', :model => 'person'}]
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['ForgotPasswordHelperTest::Plugin1', 'ForgotPasswordHelperTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_includes fields, 'f1'
    assert_includes fields, 'f2'
    assert_includes fields, 'f3'
  end

  should 'allow extra person fields provided by plugins' do
    class Plugin1 < Noosfero::Plugin
      def change_password_fields
        {:field => 'f1', :name => 'F1', :model => 'person'}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def change_password_fields
        [{:field => 'f2', :name => 'F2', :model => 'user'},
         {:field => 'f3', :name => 'F3', :model => 'person'}]
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['ForgotPasswordHelperTest::Plugin1', 'ForgotPasswordHelperTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_includes person_fields, 'f1'
    assert_not_includes person_fields, 'f2'
    assert_includes person_fields, 'f3'
  end

  should 'allow extra user fields provided by plugins' do
    class Plugin1 < Noosfero::Plugin
      def change_password_fields
        {:field => 'f1', :name => 'F1', :model => 'user'}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def change_password_fields
        [{:field => 'f2', :name => 'F2', :model => 'person'},
         {:field => 'f3', :name => 'F3', :model => 'user'}]
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['ForgotPasswordHelperTest::Plugin1', 'ForgotPasswordHelperTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_includes user_fields, 'f1'
    assert_not_includes user_fields, 'f2'
    assert_includes user_fields, 'f3'
  end

  should 'add plugins fields labels to final label' do
    class Plugin1 < Noosfero::Plugin
      def change_password_fields
        {:field => 'f1', :name => 'F1', :model => 'user'}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def change_password_fields
        [{:field => 'f2', :name => 'F2', :model => 'person'},
         {:field => 'f3', :name => 'F3', :model => 'user'}]
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['ForgotPasswordHelperTest::Plugin1', 'ForgotPasswordHelperTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_match /F1/, fields_label
    assert_match /F2/, fields_label
    assert_match /F3/, fields_label
  end

  should 'fetch requestors based on fields available' do
    p1 = create_user('person1').person
    p2 = create_user('person2').person

    requestors = fetch_requestors('person1')
    assert_includes requestors, p1
    assert_not_includes requestors, p2

    p3 = create_user('person3').person
    p3.address = 'some address'
    p3.save!
    p4 = create_user('person4').person
    p4.address = 'some address'
    p4.save!
    p5 = create_user('person5').person
    p5.address = 'another address'
    p5.save!

    self.stubs(:person_fields).returns(%w[address])
    requestors = fetch_requestors('some address')
    assert_includes requestors, p3
    assert_includes requestors, p4
  end

  should 'not fetch people from other environments' do
    p1 = create_user('person', :environment => fast_create(Environment)).person
    p2 = create_user('person').person

    requestors = fetch_requestors('person')
    assert_not_includes requestors, p1
    assert_includes requestors, p2
  end
end
