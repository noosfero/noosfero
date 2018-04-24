require_relative "../test_helper"

class ExporterTest < ActiveSupport::TestCase
  def setup
    @person = create_user('test').person
    @fields = { base: %w[name], user: %w[login] }
    @exporter = Exporter.new(Person.all, @fields)
  end

  should 'extract base fields correctly' do
    assert_equal @fields[:base], @exporter.base_fields
  end

  should 'extract related fields correctly' do
    assert_equal @fields.except(:base), @exporter.related_fields
  end

  should 'include base fields on resulting csv' do
    content = @exporter.to_csv
    assert_match @person.name, content
  end

  should 'include relation fields on resulting csv' do
    content = @exporter.to_csv
    assert_match @person.user.login, content
  end

  should 'include base fields on resulting xml' do
    content = @exporter.to_xml
    assert_match @person.name, content
  end

  should 'include relation fields on resulting xml' do
    content = @exporter.to_xml
    assert_match @person.user.login, content
  end
end
