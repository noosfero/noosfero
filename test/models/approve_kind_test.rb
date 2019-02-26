require_relative "../test_helper"

class ApproveKindTest < ActiveSupport::TestCase

  def setup
    @requestor = create_user('requestor').person
    @kind = Kind.create!(:name => 'Star', :type => 'Person', :environment => Environment.default)
  end

  attr_accessor :requestor, :kind

  should 'validate presence of requestor' do
    task = ApproveKind.new
    task.valid?
    assert task.errors[:requestor_id].present?
  end

  should 'validate presence of target' do
    task = ApproveKind.new
    task.valid?
    assert task.errors[:target_id].present?
  end

  should 'have kind' do
    task = ApproveKind.new
    task.kind = kind

    assert_equal kind, task.kind
  end

  should 'add kind to profile on finish' do
    task = ApproveKind.create!(:requestor => requestor, :target => Environment.default, :kind => kind)
    task.finish

    assert_includes requestor.kinds, kind
  end

end
