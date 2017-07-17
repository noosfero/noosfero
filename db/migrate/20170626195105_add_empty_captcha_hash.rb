class AddEmptyCaptchaHash < ActiveRecord::Migration
  def change
    Environment.all.each do |environment|
      environment.metadata["captcha"] = {}
      environment.save
    end
  end
end
