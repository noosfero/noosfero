class MainBlock < Block

  def content(main_content = nil)
    main_content + "(id: ##{self.id})"
  end

end
