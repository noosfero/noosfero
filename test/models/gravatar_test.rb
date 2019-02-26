require_relative "../test_helper"

class GravatarTest < ActiveSupport::TestCase

  def setup
    @object = Object.new
    @object.extend(Noosfero::Gravatar)
  end

  should 'generate a gravatar image url' do
    url = @object.gravatar_profile_image_url( 'rms@gnu.org', :size => 50, :d => 'crazyvatar' )
    assert_match(/^\/\/www\.gravatar\.com\/avatar\/ed5214d4b49154ba0dc397a28ee90eb7?/, url)
    assert_match(/(\?|&)d=crazyvatar(&|$)/, url)
    assert_match(/(\?|&)size=50(&|$)/, url)

    url = @object.gravatar_profile_image_url( 'rms@gnu.org', :size => 50, :d => 'nicevatar' )
    assert_match(/^\/\/www\.gravatar\.com\/avatar\/ed5214d4b49154ba0dc397a28ee90eb7?/, url)
    assert_match(/(\?|&)d=nicevatar(&|$)/, url)
    assert_match(/(\?|&)size=50(&|$)/, url)
  end

  should 'generate a gravatar profile url' do
    url = @object.gravatar_profile_url( 'rms@gnu.org' )
    assert_equal('//www.gravatar.com/ed5214d4b49154ba0dc397a28ee90eb7', url)
  end
end
