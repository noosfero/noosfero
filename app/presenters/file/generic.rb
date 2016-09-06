# Made to encapsulate any UploadedFile
class FilePresenter::Generic < FilePresenter
  # if returns low priority, because it is generic.
  def self.accepts?(f)
    1 if f.is_a? UploadedFile
  end
end
