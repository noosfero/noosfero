ActionDispatch::Reloader.to_prepare do
  Spammable.module_eval do
    def marked_as_spam
      plugins.dispatch(:marked_as_spam, self)
    end

    def marked_as_ham
      plugins.dispatch(:marked_as_ham, self)
    end

    def check_for_spam
      plugins.dispatch(:check_for_spam, self)
    end
  end
end
