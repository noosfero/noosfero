require File.dirname(__FILE__) + '/../test_helper'

class NoosferoFilenamesTest < ActiveSupport::TestCase

  include ShortFilename

  should 'trunc to 15 chars the big filename' do
    assert_equal 'AGENDA(...).mp3', short_filename('AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA.mp3',15)
  end

  should 'trunc to default limit the big filename' do
    assert_equal 'AGENDA_CULTURA_-_FESTA_DE_VAQUEIRO(...).mp3', short_filename('AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA.mp3')
  end

  should 'does not trunc short filename' do
    assert_equal 'filename.mp3', short_filename('filename.mp3')
  end

end

