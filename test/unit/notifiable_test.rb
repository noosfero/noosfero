require_relative '../test_helper'

class NotifiableTest < ActiveSupport::TestCase

  class Foo
    include Notifiable
  end

  should 'configure a new notification verb' do
    Foo.will_notify :new_things
    assert Foo.new.respond_to?(:new_things_settings, true)
  end

  should 'use default options for configured notifications' do
    Foo.will_notify :new_things
    assert_equal false, Foo.new.send(:new_things_settings)[:push]
  end

  should 'override default options for configured notifications' do
    Foo.will_notify :new_things, push: true
    assert Foo.new.send(:new_things_settings)[:push]
  end

  should 'accept custom options for configured notifications' do
    Foo.will_notify :new_things, custom: 42
    assert_equal 42, Foo.new.send(:new_things_settings)[:custom]
  end

  should 'return nil if mailer class is not defined' do
    assert Foo.mailer_for_class.nil?
  end

  should 'return respective mailer class if it is defined' do
    class FooMailer; end
    assert_equal FooMailer, Foo.mailer_for_class
    NotifiableTest.send(:remove_const, :FooMailer)
  end

  should 'raise an exception when notifying a non configured verb' do
    assert_raise Notifiable::UnregisteredVerb do
      Foo.new.notify :unregistered_things
    end
  end

  should 'notify by mail and push if the verb is registered' do
    Foo.will_notify :new_things
    Foo.any_instance.expects(:notify_by_mail).once
    Foo.any_instance.expects(:notify_by_push).once
    Foo.new.notify(:new_things)
  end

  should 'deliver message when notifying by mail and mailer is defined' do
    msg = mock
    class FooMailer; end
    FooMailer.stubs(:new_things).returns(msg)
    msg.expects(:deliver).once

    Foo.will_notify :new_things
    Foo.new.send(:notify_by_mail, :new_things)
    NotifiableTest.send(:remove_const, :FooMailer)
  end

end
