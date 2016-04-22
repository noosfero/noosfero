require_relative "../test_helper"

class MultiTenancyTest < ActionDispatch::IntegrationTest

  should 'change postgresql schema' do
    host! 'schema1.com'
    Noosfero::MultiTenancy.expects(:on?).at_least_once.returns(true)
    Noosfero::MultiTenancy.expects(:mapping).returns({ 'schema1.com' => 'schema1' }).at_least_once
    exception = assert_raise(ActiveRecord::StatementInvalid) { get '/' }

    # we have switched to a new database schema; depending on the PostgreSQL
    # version, we will receive either an error message because the schema
    # does not exist, or an error saying that whatever table we need can't be
    # found.
    assert_match /(SET search_path TO schema1|PG::UndefinedTable)/, exception.message
  end

  should 'not change postgresql schema if multitenancy is off' do
    host! 'schema1.com'
    Noosfero::MultiTenancy.stubs(:on?).returns(false)
    Noosfero::MultiTenancy.stubs(:mapping).returns({ 'schema1.com' => 'schema1' })
    assert_nothing_raised(ActiveRecord::StatementInvalid) { get '/' }
  end

  should 'find session from the correct database schema' do
    Noosfero::MultiTenancy.expects(:on?).at_least_once.returns(true)
    Noosfero::MultiTenancy.expects(:mapping).returns({ 'schema2.com' => 'public', 'schema1.com' => 'schema1' }).at_least_once

    user = create_user
    session_obj = create(Session, user_id: user.id, session_id: 'some_id', data: {})
    person_identifier = user.person.identifier

    Noosfero::MultiTenancy.setup!('schema1.com')
    host! 'schema2.com'
    cookies[:_noosfero_session] = session_obj.session_id
    assert_nothing_raised { get "/myprofile/#{person_identifier}" }
    assert_equal 'public', ApplicationRecord.connection.schema_search_path
  end

end
