require_relative "../test_helper"

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

  should 'highlight the file extansion' do
    assert_equal 'AGENDA(...) - MP3', short_filename_upper_ext('AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA.mp3',15)

    assert_equal 'AGENDA - MP3', short_filename_upper_ext('AGENDA.mp3',15)
  end

  should 'return the full filename if its size is smaller than the limit' do
    assert_equal 'AGENDA', shrink('AGENDA', 'mp3', 15)
  end

  should 'shrink the filename if its size is bigger than the limit' do
    assert_equal 'AGENDA(...)', shrink('AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA', 'mp3', 14)
  end

end

