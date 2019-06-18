class AddEmptyCaptchaHash < ActiveRecord::Migration[4.2]
  def change
    Environment.all.each do |environment|
      environment.metadata["captcha"] = {}
      environment.save
    end
  end
end
